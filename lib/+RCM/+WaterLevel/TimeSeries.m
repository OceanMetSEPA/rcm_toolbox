classdef TimeSeries < RCM.TimeSeries.Base & RCM.TimeSeries.TotalTide
    
    % Detailed explanation goes here
    
    properties
        Height      = [];
        isSlack     = [];
        isHighWater = [];
        TidalRange  = []; 
    end
    
    methods (Static = true)
        
        function WL = create(time, height, varargin)
            % Returns an instance of RCM.WaterLevel.TimeSeries based upon
            % the passed in time and height vectors.
            %
            % Slack water level information (e.g. slack indexes, high water
            % indexes, tidal ranges) are automatically computed.
            %
            
            WL = RCM.WaterLevel.TimeSeries;
            
            WL.Time = time;
            WL.Height = height;
            
            for a = 1:2:length(varargin)
              try
                  WL.(varargin{a}) = varargin{a + 1};
              catch
                  warning([varargin{a}, ' is not a valid property'])
              end
            end
            
            WL.calculateSlackInfo; 
            WL.calculateTidalRanges;
        end
        
        function wl = fromTotalTideStruct(str, varargin)
            % Returns an instance of RCM.WaterLevel.TimeSeries based upon
            % the passed in struct, the format of which is the same as that
            % outputted by TotalTide 'get height' functions.
            %
            % Slack water level information (e.g. slack indexes, high water
            % indexes, tidal ranges) are automatically computed.
            %
            wl = RCM.WaterLevel.TimeSeries.create(str.time', str.height', varargin{:});
        end
        
        function wl = fromTotalTide(startDate, lengthDays, varargin)
            % Returns the tidal heights at the nearest TotalTide port
            % location for the period specified by *offset* and *length*.
            %
            % *startDate* represents the start date of the TotalTide water
            % levels.
            %
            % *lengthDays* represents the number of days required for the
            % TotalTide water level record.
            %
            % 
            
            % Ensure the TotalTide package is available
            RCM.TimeSeries.TotalTide.isPackageAvailable;
                        
            resolution = 60;
            slack      = 0;
            port       = [];
            easting    = [];
            northing   = [];
            latitude   = [];
            longitude  = [];
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'resolution'
                        resolution = varargin{i + 1};
                      case 'slack'
                        slack = varargin{i + 1};
                      case 'port'
                        port = varargin{i + 1};
                      case 'easting'
                        easting = varargin{i + 1};
                      case 'northing'
                        northing = varargin{i + 1};
                      case 'latitude'
                        latitude = varargin{i + 1};
                      case 'longitude'
                        longitude = varargin{i + 1};
                    end
                end   
            end
            
            if ~isequal(class(port), 'Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort') & ...
                    ~isequal(class(port), 'Interface.A0F2755E_49A9_4E2E_B72E_C41D51477D0B') % new version class description
               if isnumeric(easting) && isnumeric(northing) && ~isempty(easting) && ~isempty(northing)
                   port = TotalTide.closestPort(easting, northing, 'format', 'OSGB');
               elseif isnumeric(latitude) && isnumeric(longitude) && ~isempty(latitude) && ~isempty(longitude)
                   port = TotalTide.closestPort(latitude, longitude);
               else
                   error('RCM:InvalidArgument', 'Insufficient data to locate nearest Total Tide port. Specify a port object, easting/northing or lat/long.');                   
               end
            end
                        
            if slack
                ttStruct = TotalTide.getSlackHeights(port, ...
                    startDate, ...
                    lengthDays);
            else
                ttStruct = TotalTide.getHeights(port, ...
                    startDate, ...
                    lengthDays, ...
                    resolution);
            end
            
            wl = RCM.WaterLevel.TimeSeries.fromTotalTideStruct(ttStruct,varargin{:});
            
            wl.TotalTidePort = port;
            wl.Latitude      = port.Latitude;
            wl.Longitude     = port.Longitude;
            
            if ~isempty(easting)
                wl.Easting = easting;
            end
            
            if ~isempty(northing)
                wl.Northing = northing;
            end
        end
        
        function [isSlack, isHighWater] = findSlackWaterPoints(data, scale)
            % Returns ... 
            %
            % The scale parameter represents how many datapoints around
            % each candidate turning point to search for maxima or minima. This
            % helps to avoid false turning points. A useful rule of thumb
            % is to use the number of datapoints that comprise about half
            % of the expected cycle period.

            % This works by doing two things
            %
            %  1. identify candidate turning points (peaks or troughs) by looking
            %     to see where the difference between consectutive points changes
            %     sign, i.e. shifts from positive to negative. This represents a
            %     change in the direction of the gradient and therefore indicates
            %     the location of a local peak or trough
            %
            %  2. we want to avoid very local peaks or troughs in cases where the
            %     data is noisy and only locate single peaks and troughs for individual
            %     flood and ebb tides. So we look around each candidate to make
            %     sure it is a maximum or minimum of the points around it. We don't
            %     want to look too far otherwise we might find another valid peak
            %     or trough, so we use the scale argument to determine how far to
            %     check around each candidate point. The appropriate size of the scale
            %     parameter will be related to the density of the observations.
            %
           
            
            isSlack     = zeros(length(data),1);
            isHighWater = zeros(length(data),1);
            
            isSlack(1)     = 0;
            isHighWater(1) = 0;
            
            % Get the differences between consecutive observations
            deltas = diff(data);

            % Iterate through the diff and check where the sign changes (i.e.
            % passing a peak or trough), then act accordingly.
            for i = 2:size(deltas,1)
               if sign(deltas(i)) ~= sign(deltas(i-1))

                   % Determine the look ahead and look back distances. In most
                   % cases these will simply be equal to the scale parameter,
                   % except where we are near the beginning or end of the
                   % iteration.
                   look_ahead = min([scale, size(deltas,1) - i]);
                   look_back  = min([scale, i-1]);

                   % Get the local values around this point
                   localSequence = data(i-look_back:i+look_ahead);

                   if sign(deltas(i)) == -1 % leaving peak, we are at a local maximum

                       % Find the value of the maximum value within the local
                       % sequence. If our value is the max value, we might want to
                       % use it. We want to make sure there aren't two or more
                       % points which happen to equal this maximum value though so
                       % we don't end up with  multiple points representing the
                       % same slack water (peak or trough).

                       localMax = max(localSequence); % maximum value
                       localMaxIndexes = find(localSequence == localMax);

                       % If more than one value in the local sequence is the
                       % maximum then we only want to use it if it is the last one
                       % (which is just an arbitrary choice). Skip if that is not
                       % the case
                       if size(localMaxIndexes,1) > 1 && any(localMaxIndexes > look_back +1)
                           continue
                       end

                       if data(i) == localMax
                           isSlack(i)     = 1;
                           isHighWater(i) = 1;
                       end
                   else % leaving trough, we are at a local minimum

                       % Use same logic as above to avoid identifying multiple
                       % maxima from local sequence

                       localMin = min(localSequence);
                       localMinIndexes = find(localSequence == localMin);

                       if size(localMinIndexes,1) > 1 && any(localMinIndexes > look_back +1)
                           continue
                       end

                       if data(i) == localMin
                           isSlack(i) = 1;
                       end
                   end
               end
            end
        end
    end
    
    methods
        
        function calculateSlackInfo(WL)
            % Sets the isSlack and isHighWater properties by identifying the 
            % slack water points and calculating the associated tidal ranges.
            %
            
            [WL.isSlack, WL.isHighWater] = RCM.WaterLevel.TimeSeries.findSlackWaterPoints(WL.Height, ...
                    WL.dataPointsPerSemiDiurnalHalfCycle);
                
            if WL.isSlackOnly
                % If a slack-only dataset, we know all the points are
                % slack. This will have been identified by the class method
                % above, but with the exception of the first and last
                % datapoints. These cannot be identified as slack points
                % (maxima or minima) using a generalised method since they
                % are at the edge of the dataset. So just set the isSlack 
                % property vector to all 1's to catch those end points that 
                % we know are slack in this case.
                WL.isSlack = ones(WL.length,1);
                
                % The isHighWater property has been set above, but, again, the
                % class method used assumes that the start and end values
                % are not slack and therefore not high water. Since we know 
                % the dataset, in this case, is slack-only, we need to identify 
                % whether these end values are high or low.
                
                if WL.Height(1) > WL.Height(2)
                    WL.isHighWater(1) = 1;                    
                end
                
                if WL.Height(end) > WL.Height(end-1)
                    WL.isHighWater(end) = 1;                    
                end
            end
        end
        
        function calculateTidalRanges(WL)
            % Sets the TidalRange property, which describes the
            % semi-diurnal tidal range associated with each data point.
            
            if isempty(WL.isSlack)
                WL.calculateSlackInfo;
            end
            
            ranges = diff(WL.slackHeight);
            slackInxs = WL.slackIndexes;

            % Start with NaNs. This means that the tidal ranges at any data 
            % points before the first and after the last slack points remain 
            % undefined.
            WL.TidalRange = nan(WL.length,1);

            for i = 1:length(slackInxs)-1
               WL.TidalRange(slackInxs(i):slackInxs(i+1),1) = ranges(i);
            end
        end
         
        function ism = isSpringMax(WL)
            % Returns a data vector of booleans corresponding to each data point 
            % in the time series describing whether or not the data point
            % is a maximum high or low tide within the spring-neap cycle.
            
            [ism, ~] = RCM.WaterLevel.TimeSeries.findSlackWaterPoints(WL.Height, ...
                WL.dataPointsPerSpringNeapCycle/2);
        end
        
        function m = mean(WL)
            % Returns the mean water level across the time series.
            
            m = mean(WL.Height);
        end
        
        function m = min(WL)
            % Returns the minimum water level across the time series.
            
            m = min(WL.Height);
        end
        
        function m = max(WL)
            % Returns the maximum water level across the time series.
            
            m = max(WL.Height);
        end
        
        function g = gradient(WL)
            g = gradient(WL.Height);
        end
        
        function r = ranges(WL)
            % Returns a vector representing the tidal ranges of each flood
            % and ebb tide.
            %
            % The first and last tidal range values may be undefined (NaN)
            % because tidal range cannot be identified at the dataset
            % endpoints where the identification of slack water is ambiguous.
            % Exceptions to this are "slack-only" instances, wherein
            % every point is known to be a slack water level, and cases
            % where the time series has been truncated from a longer
            % dataset in which tidal ranges were determined prior to
            % truncating.
            %
            
            if WL.isSlackOnly
                r = diff(WL.slackHeight);
            else
                % We assume that start and endpoints are not slack points,
                % therefore we can calculate a range. Use NaNs.
                r = [NaN; diff(WL.slackHeight); NaN];

                % But if ranges determined already from longer dataset, use
                % them.
                if ~isnan(WL.TidalRange(1))
                    r(1) = WL.TidalRange(1);
                end

                if ~isnan(WL.TidalRange(end))
                    r(end) = WL.TidalRange(end);
                end
            end
        end
        
        function mr = meanRange(WL)
            % Returns the mean tidal range across the time series. 
            absRanges = abs(WL.ranges);
            mr = mean(absRanges(~isnan(absRanges)));
        end
        
        function mr = minRange(WL)
            % Returns the minimum tidal range across the time series. 
            
            mr = min(abs(WL.ranges));
        end
        
        function mr = maxRange(WL)
            % Returns the maximum tidal range across the time series. 
            
            mr = max(abs(WL.ranges));
        end
                
        function idx = slackIndexes(WL)
            % Returns a vector describing the indexes of each semi-diurnal 
            % slack water data point in the time series.
            
            if isempty(WL.isSlack)
                WL.calculateSlackInfo;
            end
            
            idx = find(WL.isSlack);
        end
                
        function idx = highWaterIndexes(WL)
            % Returns a vector describing the indexes of each semi-diurnal
            % high water data point in the time series.
            
            idx = find(WL.isHighWater);
        end
          
        function idx = lowWaterIndexes(WL)
            % Returns a vector describing the indexes of each semi-diurnal
            % low water data point in the time series.
            
            idx = find(WL.isSlack & ~WL.isHighWater);
        end
        
        function st = slackTime(WL)
            % Returns a vector describing the time of each semi-diurnal
            % slack water data point in the time series.
            
            st = WL.Time(WL.slackIndexes);
        end
        
        function sh = slackHeight(WL)
            % Returns a vector describing the height of each semi-diurnal
            % slack water data point in the time series.
            
            sh = WL.Height(WL.slackIndexes);
        end
        
        function csh = closestSlackHeights(WL)
            % Returns a vector describing the height of the nearest semi-diurnal
            % slack water height to each point in the time series.
            
            if isempty(WL.isSlack)
                WL.calculateSlackInfo;
            end
            
            slackHeights = WL.slackHeight;
            slackInxs    = WL.slackIndexes;
            normalisedHeights = WL.Height - WL.mean;

            csh = nan(WL.length,1);
            csh(1:slackInxs(1),1) = slackHeights(1);
            
            for slw = 1:length(slackInxs)-1
                
               theseIdxs = slackInxs(slw):slackInxs(slw+1);
               
               for ts = theseIdxs
                   if sign(normalisedHeights(ts)) == sign(slackHeights(slw))
                        csh(ts) = slackHeights(slw);
                   else
                        csh(ts) = slackHeights(slw+1);
                   end
               end                  
               
            end
            
            csh(slackInxs(end):end,1) = slackHeights(end);
        end
        
        function sws = slackWaterState(WL)
            % Returns a vector describing the position of every data point
            % relative to the semi-diurnal cycle. A value of 1 represents
            % high water and a value of -1 represents low water.
            
            if WL.length < WL.dataPointsPerSemiDiurnalHalfCycle
                error('Time series shorter than semi-diurnal cycle');
            end
             
            sws = WL.Height./abs(WL.closestSlackHeights);
        end
        
        function sws = slackWaterStage(WL)
            % Returns a vector describing the position of every data point
            % relative to the semi-diurnal cycle. Each data point is
            % described by a value between 0 and 1, with 0 indicating a
            % high water slack tide level and 1 indicating the next high
            % water slack level
            %
            % This function is distinct from the similarly named
            % .slackWaterState() in that this function enables the
            % direciton of the cycle to be identified. For example,
            % .slackWaterState describes a similar water level identically
            % irrespective of whether it, for example, precedes high water
            % or follows high water. This function allows the stage to be
            % specifically identified - in this case a value close to 0
            % indicates following high water and a value close to 1
            % approaching high water.
            
            if WL.length < WL.dataPointsPerSemiDiurnalHalfCycle
                error('Time series shorter than semi-diurnal cycle');
            end
             
            hwi = WL.highWaterIndexes;
            
            sws = nan(WL.length,1);
            
            leadingCount = hwi(1);
            leadingProportion = leadingCount/(2.0*WL.dataPointsPerSemiDiurnalHalfCycle);
            
            sws(1:hwi(1),1) = linspace(1-leadingProportion, 1, leadingCount);
            
            for hw = 1:length(hwi)-1
               theseIdxs = hwi(hw):hwi(hw+1);
               sws(theseIdxs) = linspace(0,1,length(theseIdxs));               
            end
            
            trailingCount = WL.length - hwi(end) + 1;
            trailingProportion = trailingCount/(2.0*WL.dataPointsPerSemiDiurnalHalfCycle);
            
            sws(hwi(end):end,1) = linspace(0, trailingProportion, trailingCount);
        end
        
        function fsmi = firstSpringMaxIndex(WL)
            fsmi = find(WL.Height(1:WL.dataPointsPerSpringNeapCycle) == max(WL.Height(1:WL.dataPointsPerSpringNeapCycle)));
            if length(fsmi) > 1
                fsmi = fsmi(1);
            end
        end
        
        function issni = isSpringNeapInflection(WL)
            % Returns a boolean vector describing whether each data point
            % represents the transition point from spring to neap or vice
            % versa. Obviously, most points are 0, with only the transition
            % points = 1.
            
            issni = diff(WL.isSpringOrNeap) ~= 0;
        end
        
        function snph = springNeapState(WL)
            % Returns a vector describing the position of every data point
            % relative to the spring-neap cycle. A value of 1 represents peak
            % spring and a value of -1 represents peak neap.
            %
            % This represents an average position in the cycle extrapolated
            % from the first identified spring max through time. It may
            % wander out of phase slightly with repsect to any specific
            % spring-neap periods.
            
            if WL.length < WL.dataPointsPerSpringNeapCycle
                error('Time series shorter than mean spring-neap cycle');
            end
            
            t = (1:WL.length)';
            w = 2*pi/RCM.Constants.Tide.SpringNeapAverageSeconds;
            
            snph = cos(w * ((t - WL.firstSpringMaxIndex).*WL.timeIntervalSeconds));
        end
        
        function sns = springNeapStage(WL)
            % Returns a vector describing the position of every data point
            % relative to the spring-neap cycle. Each data point is
            % described by a value between 0 and 1, with 0 indicating a
            % spring maximum tide level and 1 indicating the next spring
            % maximum tide level
            %
            % This function is distinct from the similarly named
            % .springNeapState() in that this function enables the
            % direciton of the cycle to be identified. For example,
            % .springNeapState describes a similar spring neap "magnitude"
            % identically irrespective of whether it, for example, precedes 
            % the spring maximum or follows it. This function allows the 
            % stage to be specifically identified - in this case a value 
            % close to 0 indicates following the spring maximum and a value 
            % close to 1 approaching spring maximum.
            
            if WL.length < WL.dataPointsPerSpringNeapCycle
                error('Time series shorter than semi-diurnal cycle');
            end
             
            smi = find(WL.isSpringMax & WL.isHighWater);
            
            sns = nan(WL.length,1);
            
            leadingCount = smi(1);
            leadingProportion = leadingCount/WL.dataPointsPerSpringNeapCycle;
            
            sns(1:smi(1),1) = linspace(1-leadingProportion, 1, leadingCount);
            
            for sm = 1:length(smi)-1
               theseIdxs = smi(sm):smi(sm+1);
               sns(theseIdxs) = linspace(0,1,length(theseIdxs));               
            end
            
            trailingCount = WL.length - smi(end) + 1;
            trailingProportion = trailingCount/WL.dataPointsPerSpringNeapCycle;
            
            sns(smi(end):end,1) = linspace(0, trailingProportion, trailingCount);
        end
        
        function iss = isSpringOrNeap(WL)
            % Returns a vector describing whether each data point
            % occurs within the spring or neap period.
            
            iss = sign(WL.springNeapPhase);
        end
        
        function bool = isSlackOnly(WL)
            % Returns a boolean describing whether the time series
            % represents slack water heights only (1) or not (0).
            
            bool = 0;
            
            d = sign(diff(WL.Height));
            odds  = d(1:2:end);
            evens = d(2:2:end);
    
            if all(odds == odds(1)) && all(evens == evens(1)) && odds(1) ~= evens(1)
                bool = 1;
            end
        end
        
        function wl = toSlackOnly(WL)
            % Returns a new instance of RCM.WaterLevel.TimeSeries
            % representing the current time series filtered to just the
            % slack water heights.
            
            indexes = WL.slackIndexes;

            wl = RCM.WaterLevel.TimeSeries.create(WL.Time(indexes), WL.Height(indexes));
        end
        
        function normalise(WL)
            % Adjusts the heights in the current time series to be
            % centralised around a mean height of zero.
            
            WL.Height = WL.Height - WL.mean;
        end
        
        function wl = toNormalised(WL)
            % Returns a new instance of RCM.WaterLevel.TimeSeries
            % representing the current time series adjusted to be
            % centralised around a mean height of zero.
            
            wl = WL.clone;
            wl.normalise;
        end
        
        function idx = equivalentTidalStageIndex(WL, targetSNS, targetSDS)
            % Returns the index of the datapoint within the final
            % spring-neap cycle that best approximates the tidal conditions
            % passed in. This is useful for identifying a data point which
            % corresponds with the conditions at a particular known point
            % in time.
            %
            
            sns = WL.springNeapStage;
            sds = WL.slackWaterStage;

            phaseDiffs = abs(sns - targetSNS) + abs(sds - targetSDS);
            lastSpringNeapPhaseDiffs = phaseDiffs(end-WL.dataPointsPerSpringNeapCycle:end);
            idxs = find(phaseDiffs == min(lastSpringNeapPhaseDiffs));
            
            idx = idxs(end);
        end
        
        function idx = equivalentStartingTidalStageIndex(WL)
            % Returns the index of the datapoint within the final
            % spring-neap cycle that best approximates the tidal conditions
            % of the starting datapoint. This is useful for identifying
            % where best to truncate a dataset for repeating purposes.
            %
            % Generally it will be appropriate to truncate a timeseries at
            % the index *before* the one returned by this function (i.e. idx
            % - 1) to ensure a minimal discontinuity when repeating time
            % series. The .truncateToStartingTidalStage() function will
            % achieve this without having to explicitly call this function.
            
            sns = WL.springNeapStage;
            sds = WL.slackWaterStage;
            
            idx = WL.equivalentTidalStageIndex(sns(1), sds(1));
        end
        
        function [sns, sds] = tidalStageByIndex(WL, idx)
            sns = WL.springNeapStage;
            sds = WL.slackWaterStage;
            
            sns = sns(idx);
            sds = sds(idx);
        end
        
        function idx = truncateToStartingTidalStage(WL)
            % Truncates the time series object to a similar tidal stage as
            % the start of the series, based on the stage through both the
            % spring-neap and flood-ebb cycle. This is useful for repeating
            % a dataset and minimising discontinuities.
            %
            % If the time series object is shorter than the average spring-
            % neap cycle an error is raised.
            %
          
            idx = WL.equivalentStartingTidalStageIndex - 1;
                        
            WL.truncateByIndex('endIndex', idx);
        end
        
        function h = plot(WL)
            % Generates a plot of the current time series water level
            % heights versus time.
            
            %figure;
            h = plot(WL.Time, WL.Height);
            grid on;
            
            set(gca, 'XTick', WL.Time(ceil(linspace(1,size(WL.Time,1),5))));
            set(gca, 'XTickLabel', datestr(WL.Time(ceil(linspace(1,size(WL.Time,1),5))),2));
            xlabel('Date');
            ylabel('Water level (m)');
            title('Water level and peaks/troughs');
        end
        
        function h = plotWithSlackPoints(WL) 
            % Generates a plot of the current time series water level
            % heights versus time and annotates the data points
            % representing slack water.
            
            h = WL.plot;
            hold on;
            
            highIdxs = WL.highWaterIndexes;
            plot(WL.Time(highIdxs), WL.Height(highIdxs), 'ro');
            
            lowIdxs = WL.lowWaterIndexes;
            plot(WL.Time(lowIdxs), WL.Height(lowIdxs), 'go');

            hold off;
        end
        
    end
    
end

