classdef Base < dynamicprops
    
    % This class provides functionality for handling and manipulating time
    % series data. The intention is that this class will be subclassed and
    % that any subclasses will introduce the specific time series vectors
    % for the intended context. This class provides only the the Time
    % vector but the many generic methods are designed to operate on the
    % additional subclass data vectors.
    %
    % To document:
    %
    %   get.Property methods can be cleared. These are considered to be
    %   derived from the raw data
    %
    %   Raw data do not use get.Property methods.
    %
    %   Vector properties with the same length as Time will be treated as
    %   fundamental data vectors for truncating, repeating, etc.
    %
    %   Time interval assumes regularity.
    %
    
    properties 
        Time@double = [];
        
        Easting@double   = NaN;
        Northing@double  = NaN;
        Latitude@double  = NaN;
        Longitude@double = NaN;
    end
    
    methods
        
        function l = length(B)
            % Returns the number of observations in the TimeSeries object
            
            l = length(B.Time);
        end
        
        function [dn] = startTime(B)
            % Returns the start time of the TimeSeries object as a datenum
            
            dn = B.Time(1);
        end
        
        function [de] = endTime(B)
            % Returns the end time of the TimeSeries object as a datenum
            
            de = B.Time(end);
        end
        
        function [l] = lengthDays(B)
            % Returns the length, in days, represented by the TimeSeries object
            
            l = (B.endTime-B.startTime);
        end
        
        function [seconds] = timeIntervalSeconds(B)
            % Returns the time interval between observations in seconds.
            % This is calculated as the mean difference in time between 
            % consecutive observations and therefore implies that the time
            % interval is regular.
            
            seconds = mean(diff(B.Time))*24*60*60;
        end
        
        function d = dataPointsPerSemiDiurnalHalfCycle(B)
            % Returns the number of observations in half a semi-diurnal
            % tidal cycle.
            
            d = floor(RCM.Constants.Tide.SemiDiurnalHalfCycleSeconds/B.timeIntervalSeconds);
        end
        
        function d = dataPointsPerSpringNeapCycle(B)
            % Returns the number of observations in an average spring-neap
            % tidal cycle.
            
            d = round(RCM.Constants.Tide.SpringNeapAverageSeconds / B.timeIntervalSeconds);
        end
        
        function n = springNeapCycleCount(B)
            % Returns the number of spring-neap cycles represented in the TimeSeries
            % object
            
            n = B.lengthDays/RCM.Constants.Tide.SpringNeapAverageDays;        
        end
        
        function indxs = springNeapCycleIndexes(B, varargin)
            % Returns the indexes of the time series data points which
            % represent the specified spring-neap cycle. 
            %
            % By default, the indexes of the first spring-neap cycle of 
            % observations are returned, starting with the first observation and 
            % extending through an average spring-neap duration. Subsequent 
            % spring-neap phases can be specified using the 'cycle' option 
            % which should be an integer representing the nth spring-neap 
            % phase.
            %
            % A particular starting point for the spring-neap cycles can be
            % specified using the 'offset' option which should be an
            % integer representing the number of observations to skip at
            % the start.
            %
            % If there are insufficient datapoints in the TimeSeries object
            % to accommodate the requested number of cycles or offset, and
            % error is raised.
            %
            
            cycle = 1;
            offset  = 0;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'cycle'
                        cycle = varargin{i + 1};
                      case 'offset'
                        offset = varargin{i + 1};
                    end
                end   
            end
            
            pointsPerCycle = B.dataPointsPerSpringNeapCycle;
            
            startPoint = 1 + offset + pointsPerCycle * (cycle-1);
            endPoint   = startPoint + pointsPerCycle;
            
            if endPoint > B.length
                id  = 'RCM:TimeSeries:InsufficientData';
                msg = ['The ', class(B), ' object does not cover the requested number of spring-neap cycles and/or offset.'];
                error(id, msg);
            end
            
            indxs = startPoint:endPoint;      
        end
        
        function [idx, bool] = closestRecordToTimeIndex(B, time)
            % Returns the closest index the reference time provided, which
            % should be a MATLAB datenum. The second output is a boolean
            % which indicates whether the datenum provided is actually overlapping 
            % with the time series
            
            bool = 0;
            
            if time <= B.Time(1)
                idx = 1;
            elseif time >= B.Time(end)
                idx = B.length;
            else
                bool = 1;
                
                % First, find the previous and subsequent time records around the
                % start data
                previous_indices = find(B.Time <= time);
                previous_index   = previous_indices(end);
                subsequent_index = previous_index + 1;

                % Now, calculate the time difference of each record from the
                % reference time
                subsequentTimeDiscrepancy = B.Time(subsequent_index) - time;
                previousTimeDiscrepancy   = time - B.Time(previous_index);

                % Choose the closest
                if subsequentTimeDiscrepancy < previousTimeDiscrepancy
                    idx = subsequent_index;
                else
                    idx = previous_index;
                end  
            end
        end
        
        function l = derivedPropertyNames(B)
            % Lists the names of all "derived" properties. These are those
            % that have get.Property methods defined and are therefore
            % calculated and memoized automatically on retreival.
            %
            % Other properties may be derived from instance data using
            % more specific methods, and are not included herein.
            %
            
            meta = metaclass(B);
            
            % Find properties with a get.Property method
            derivedPropertyIndexes = cellfun(@(x) ~isempty(x), {meta.PropertyList.GetMethod});
            l = {meta.PropertyList(derivedPropertyIndexes).Name};
        end
        
        function l = nonDerivedPropertyNames(B)
            % Lists the names of all "non-derived" properties. These are those
            % that do not have get.Property methods defined and therefore
            % must be provided explicitly or derived using more specific
            % methods.
            %
            
            meta = metaclass(B);
            
            % Find properties without a get.Property method
            derivedPropertyIndexes = cellfun(@(x) isempty(x), {meta.PropertyList.GetMethod});
            l = {meta.PropertyList(derivedPropertyIndexes).Name};
        end
        
        function l = listTimeStepProperties(B)
            % Lists the names of all properties which describe time series
            % data - that is, include a data point for each time step in
            % the time series.
            %
            
            meta = metaclass(B);
            
            % Find properties with same length as time vector
            timeStepPropertyIndexes = cellfun(@(x) length(B.(x)) == B.length, {meta.PropertyList.Name});
            l = {meta.PropertyList(timeStepPropertyIndexes).Name};
        end
        
        function clearDerivedProperties(B, varargin)
            % Clears all the derived properties on the object. Derived
            % properties are identified by the presence of a get.Property
            % method. On the next retrieval of such a property it will be
            % re-derived. Therefore this method functions to refresh any
            % derived properties. This is useful after cloning or
            % truncating objects of this class or subclasses, for example.
            %
            % If there are any properties that should be excepted from this
            % refreash then these can be specified using the 'except'
            % option with the name(s) of excepted properties passed in with
            % the associated cell array.
            %
            
            exceptions = {};
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    switch varargin{i}
                      case 'except'
                        exceptions = varargin{i + 1};
                    end
                end   
            end
            
            meta = metaclass(B);
            
            % Find properties with a get.Property method that are not in
            % the exception list
            derivedPropertyIndexes = find(cellfun(@(x) ~isempty(x), {meta.PropertyList.GetMethod}) & ...
                cellfun(@(x) ~any(ismember(exceptions,x)), {meta.PropertyList.Name}));
            
            for p = 1:length(derivedPropertyIndexes)
                B.(meta.PropertyList(derivedPropertyIndexes(p)).Name) = [];
            end
        end
        
        function b = clone(B)
            % Returns a new object which is a clone of the current time series 
            % object
            
            b = eval(class(B));     
            meta = metaclass(b);
            
            % Ensure raw data is cloned first so that derived properties
            % can be set correctly.
            [~, ord] = sort(cellfun(@(x) ~isempty(x), {meta.PropertyList.GetMethod}));
            
            for p = 1:length(meta.PropertyList)
                if isobject(b.(meta.PropertyList(ord(p)).Name)) && ... 
                        any(cellfun(@(x) isequal('RCM.TimeSeries.Base', x), superclasses(b)))
                    b.(meta.PropertyList(ord(p)).Name) = B.(meta.PropertyList(ord(p)).Name).clone;
                else
                    if ~isequal(meta.PropertyList(ord(p)).SetAccess, 'none')
                        b.(meta.PropertyList(ord(p)).Name) = B.(meta.PropertyList(ord(p)).Name);
                    end
                end
            end
        end
        
        function truncateByIndex(B, varargin)
            % Truncates the time series object according to the indexes
            % passed in. The time series can be truncated from the start, 
            % end or both, with the indexes specified using the
            % 'startIndex' and 'endIndex' options.
            %
            % Any derived properties are not regenerated automatically and
            % so refreshing these using the .clearDerivedProperties()
            % method might be appropriate after truncating.
            %
            
            originalLength = B.length;
            
            startIndex = 1;
            endIndex   = B.length;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'startIndex'
                        startIndex = varargin{i + 1};
                      case 'endIndex'
                        endIndex = varargin{i + 1};
                    end
                end   
            end
            
            meta = metaclass(B);
            
            if B.length > 1
                for p = 1:length(meta.PropertyList) 
                    
                    % Only truncate properties that share the same
                    % length as the time vector, i.e. properties that
                    % are represented on each time step
                    if length(B.(meta.PropertyList(p).Name)) == originalLength
                        
                        % For any properties that are also subclasses of
                        % RCM.TimeSeries.Base, invoke the truncate function
                        % recursively
                        %
                        % For any other property, just truncate as vector
                        %
                        if isobject(B.(meta.PropertyList(p).Name)) && ... 
                                any(cellfun(@(x) isequal('RCM.TimeSeries.Base', x), superclasses(B)))

                            B.(meta.PropertyList(p).Name).truncateByIndex(varargin{:});
                        else
                            B.(meta.PropertyList(p).Name) = B.(meta.PropertyList(p).Name)(startIndex:endIndex, 1);
                        end
                    end
                end
            end
        end
        
        function truncateByTime(B, varargin)
            % Truncates the time series object according to the times
            % passed in. The time series can be truncated from the start, 
            % end or both, with the times specified as datenums using the
            % 'startTime' and 'endTime' options.
            %
            % Any derived properties are not regenerated automatically and
            % so refreshing these using the .clearDerivedProperties()
            % method might be appropriate after truncating.
            %
            
            startTime = B.Time(1);
            endTime   = B.Time(end);
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    switch varargin{i}
                      case 'startTime'
                        startTime = varargin{i + 1};
                      case 'endTime'
                        endTime = varargin{i + 1};
                    end
                end   
            end
            
            startIdx = B.closestRecordToTimeIndex(startTime);
            endIdx   = B.closestRecordToTimeIndex(endTime);
            
            B.truncateByIndex('startIndex', startIdx, 'endIndex', endIdx);
        end
        
        function truncateToDays(B, requiredLengthDays)
            % Truncates the time series object to the number of days
            % specified.
            %
            % If the time series object is shorter than the specified
            % number of days an error is raised.
            %
            % Any derived properties are not regenerated automatically and
            % so refreshing these using the .clearDerivedProperties()
            % method might be appropriate after truncating.
            %
            
            % Raise error if time series shorter than specified size
            % (or should this just do nothing? Raise warning?)
            if requiredLengthDays > B.lengthDays
                error('RCM:TimeSeries:InsufficientData', ...
                    'TimeSeries is shorter than required number of days.');
            end
            
            requiredDataPoints = round((requiredLengthDays * 24 * 60 * 60) / B.timeIntervalSeconds) + 1;
            B.truncateByIndex('endIndex', requiredDataPoints);
        end
        
        function truncateToSpringNeapCycle(B)
            % Truncates the time series object to the number of days
            % repersented by an average spring-neap cycle.
            %
            % If the time series object is shorter than the average spring-
            % neap cycle an error is raised.
            %
            % Any derived properties are not regenerated automatically and
            % so refreshing these using the .clearDerivedProperties()
            % method might be appropriate after truncating.
            %
            
            B.truncateToDays(RCM.Constants.Tide.SpringNeapAverageDays);
        end
        
        function repeat(B, cycles, varargin)
            % Repeats the data within the time series for the number of
            % cycles specified. This function therefore increases the length
            % of the timeseries by a factor equal to the number of repeating
            % cycles requested.
            %
            % Cycles are specified as integers, that is, the number of
            % full, complete cycles.
            %
            % Two additional options can be used to control the nature of
            % the repeating process. By default, the entire data series,
            % from start to end, is repeated. However, a shorter repeating
            % section can be specified by using the 'repeatLength' option, which 
            % represents the number of records (from the start of the time
            % series) to include in the repeating pattern. This may be
            % useful for selecting a sample of records which represent a 
            % naturally occuring cycle such as a day or a week, or tidal cycles
            % (e.g. semi-diurnal, spring-neap). In such a case, only the number 
            % of records chosen are repeated and any subsequent records in the 
            % time series are lost, replaced by the repeated cycles. If the
            % repeatLength is greater than the total length of the time
            % series, then an error is raised.
            %
            % An other option is the 'offset' option. This option
            % enables alternating repeating cycles to be sampled a different 
            % part of the original time series - offset from the start by the 
            % number of records specfied. This can be useful for smoothing out
            % discontinuities in the repeated data. This means that the
            % time series must be long enough to accommodate two samples of data
            % offset in time by the number of records specified by the offset 
            % option. It follows that this option must be used in
            % conjunction with the repeatLength option, and that the repeat
            % length must be smaller than the original time series length
            % minus the desired offset size. If not, an error is raised.
            %
            
            % We dont want to insist that the cycles argument is an int
            % data type necessarily, but it does need to be a whole number.
            
            if ~(cycles == int16(cycles))
                error('RCM:TimeSeries:InvalidArgument', ...
                    'Number of cycles must be a whole number.');
            end
            
            originalLengthPoints = B.length;
            timeIntervalDays     = B.timeIntervalSeconds / (24 * 60 * 60);
                        
            offset       = 0;
            repeatLength = B.length;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
                    switch varargin{i}
                      case 'offset'
                        offset = varargin{i + 1};
                      case 'repeatLength'
                        repeatLength = varargin{i + 1};
                    end
                end   
            end
            
            repeatLengthDays = (repeatLength-1) * timeIntervalDays;
            
            if B.length < repeatLength || B.length < (repeatLength + offset)
                error('RCM:TimeSeries:InsufficientData', ...
                    'TimeSeries is shorter than required number of datapoints.');
            end
            
            meta = metaclass(B);
            
            times = zeros(repeatLength*cycles,1);
            
            % Repeat the datetime vector through the extended time period but
            % increment the days. Each time we repeat the original times, increment 
            % by the total number of days in the repeat length plus an extra 
            % increment representing a single additional datapoint.
            % 
            for i = 1:cycles 
                startIndex = 1 + repeatLength*(i-1);
                endIndex   = repeatLength + repeatLength * (i-1);
                
                times(startIndex:endIndex) = B.Time(1:repeatLength) + (repeatLengthDays + timeIntervalDays)*(i-1);
            end

            B.Time = times;

            if originalLengthPoints > 1
                for p = 1:length(meta.PropertyList)  
                    if isequal(meta.PropertyList(p).Name, 'Time')
                        continue;
                    end
                    
                    % Only truncate properties that share the same length as the time 
                    % vector, i.e. properties that are represented on each time step
                    %
                    if length(B.(meta.PropertyList(p).Name)) == originalLengthPoints 
                        
                        % For any properties that are also subclasses of
                        % RCM.TimeSeries.Base, invoke the repeat function
                        % recursively
                        %
                        % For any other property, just repeat as vector
                        %
                        if isobject(B.(meta.PropertyList(p).Name)) && ... 
                                any(cellfun(@(x) isequal('RCM.TimeSeries.Base', x), superclasses(B)))
                            B.(meta.PropertyList(p).Name).repeat(days, varargin{:});
                        else
                            if offset ~= 0
                                data = [];
                                
                                for i = 1:cycles
                                    % indexes describing this cycle in the
                                    % new repeating data series
                                    startIndex = 1 + repeatLength*(i-1);
                                    endIndex   = repeatLength + repeatLength * (i-1);
                                    
                                    % Indexes describing the slice of the
                                    % original data to sample
                                    sliceStartIndex = 1;
                                    sliceEndIndex   = repeatLength;
                                    
                                    % Offset sampling indexes alternately
                                    if mod(i,2) == 0
                                        sliceStartIndex = sliceStartIndex + offset;
                                        sliceEndIndex   = sliceEndIndex + offset;
                                    end
                                    
                                    data(startIndex:endIndex,1) = B.(meta.PropertyList(p).Name)(sliceStartIndex:sliceEndIndex);
                                end
                                
                                B.(meta.PropertyList(p).Name) = data;
                            else
                                startIndex = 1;
                                endIndex   = repeatLength;
                                
                                B.(meta.PropertyList(p).Name) = repmat(B.(meta.PropertyList(p).Name)(startIndex:endIndex), cycles, 1);
                            end
                            
                        end
                    end
                end
            end
        end
        
        function repeatForDays(B, requiredLengthDays, varargin)
            % Repeats the data within the time series for the number of
            % days specified. The available options are the same as for the
            % basic .repeat() method.
            %
            % If the number of days specified is shorter than the time
            % series length then the time series will simply be truncated
            % to the specified number of days without any repeating pattern
            % (unless a shorter repeating pattern is specified using the
            % repeatLength option). 
            %
            
            repeatLengthDays = B.lengthDays;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    switch varargin{i}
                      case 'repeatLength'
                        repeatLength = varargin{i + 1};
                        repeatLengthDays = (repeatLength-1) * B.timeIntervalSeconds / (60 * 60 * 24);
                    end
                end   
            end
            
            cycles = ceil(requiredLengthDays/repeatLengthDays);
            
            B.repeat(cycles, varargin{:});
            B.truncateToDays(requiredLengthDays);            
        end
        
        function repeatSpringNeapCycle(B, requiredLengthDays)
            % Repeats the data within the first spring-neap tidal cycle for the 
            % number of days specified.
            %
            % This function uses the average spring-neap period of 14.75 days. 
            % Since the average period of a semi-diurnal tidal cycle is 12 h 25 m 
            % we get 28.51 cycles in a spring-neap cycle:
            %
            %   (14.75*(24/(25/60 + 12)) = 28.51). 
            % 
            % So there are twenty-eight and a half semi-diurnal cycles in an 
            % average spring-neap cycle. This means if we just repeat a 14.75 
            % day timeseries, there will be a half a phase discrepancy between 
            % each successive repeating sequence.
            %
            % To smooth out this discontinuity, the function samples the original
            % dataset at two different starting points spearated by half a
            % semi-diurnal tidal cycle and alternates them in the repeating pattern.
            % This means that the dataset must be at least as long as the average 
            % spring-neap cycle but preferably half a semi-diurnal cycle
            % longer. The function will attempt to alternate repeating
            % cycles by half a semi-diurnal cycle, but if sufficient
            % datapoints are not available it will offset by the amount
            % possible.
            %
            % If the number of days specified or the original time series length are
            % shorter than an average spring-neap cycle then an error will be raised.
            %
            
            if B.lengthDays < RCM.Constants.Tide.SpringNeapAverageDays
                error('RCM:TimeSeries:InsufficientData', ...
                    'Timeseries is shorter than average spring-neap cycle. Cannot repeat.')
            end
            
            if requiredLengthDays < RCM.Constants.Tide.SpringNeapAverageDays
                error('RCM:TimeSeries:InvalidArgument', ...
                    'Required number of days is shorter than average spring-neap cycle. Use the .truncateToDays() method.')
            end
            
            dataPointsPerTidalHalfCycle  = B.dataPointsPerSemiDiurnalHalfCycle;
            dataPointsPerSpringNeapCycle = B.dataPointsPerSpringNeapCycle + 1;
            
            smoothingOffset = dataPointsPerTidalHalfCycle;
            
            while B.length < (dataPointsPerSpringNeapCycle + smoothingOffset)
                smoothingOffset = smoothingOffset - 1;
            end
            
            if smoothingOffset ~= dataPointsPerTidalHalfCycle
                warning('Timeries is shorter than average spring-near cycle plus a half semi-diurnal cycle. Discontinuities may occur.');
            end
           
            B.repeatForDays(requiredLengthDays, 'repeatLength', dataPointsPerSpringNeapCycle, 'offset', smoothingOffset);
        end
        
        % If latitude not known try to set it now
        function lat = get.Latitude(TS)
            if isempty(TS.Latitude) || isnan(TS.Latitude)
                TS.updateLatLng();
            end
            
            lat = TS.Latitude;
        end
        
        % If latitude not known try to set it now
        function lng = get.Longitude(TS)
            if isempty(TS.Longitude) || isnan(TS.Longitude)
                TS.updateLatLng()
            end
            
            lng = TS.Longitude;
        end
    end
    
    methods (Access = private)
        function updateLatLng(TS)
            % Sets the instance .Latitude and .Longitude properties based upon 
            % the set .Easting and .Northing properties
            
            if ~(TS.Easting == 0) && ~(TS.Northing == 0)
                [TS.Longitude,TS.Latitude] = OS.catCoordinates(TS.Easting, TS.Northing,'from','EN','to','LL');
            end
        end
     end
end

