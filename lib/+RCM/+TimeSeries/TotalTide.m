classdef (Abstract) TotalTide < handle
    % Mixin class to be used with RCM.TimeSeries.Base
    
    properties
        TotalTidePort = [];
    end
    
    methods (Static = true)
        
        function bool = isPackageAvailable(varargin)
            % Ensure the TotalTide package is available
            
            bool       = 0;
            throwError = 1;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2)
                    switch varargin{i}
                      case 'throwError'
                        throwError = varargin{i + 1};
                    end
                end
            end
            
            if ~size(what('TotalTide'),1) > 0
                if throwError
                    error('RCM:TotalTide:PackageUnavailable', ...
                        'TotalTide MATLAB package cannot be found.');
                end
            else
                bool = 1;
            end
        end
        
        function contextPlot(waterLevel, samplingStartDate, sampleLengthDays)
            % Generalised function for producing a water level timeseries
            % plot together with a highlighted time period usually
            % representing a sampling period.
            %
            % Usage:
            %
            %  RCM.TimeSeries.tidalContextPlot(time, height, samplingStartDate, sampleLengthDays, port)
            %
            % where:
            %   time: vector of datenums
            %   height: vector of water heights
            %   samplingStartDate: datenum describing the start date of the
            %   highlighted period
            %   sampleLengthDays: length in days for the highlighted period
            %   port: a TotalTide port instance
            %
            % Examples:
            %
            %  RCM.TimeSeries.tidalContextPlot(wl, 733556.522638889, 15)
            %
            
            % plot water heights
            ts = waterLevel.plot;
            hold on;
            
            % highlight time period
            ylim = get(gca,'YLim')
            a = area([samplingStartDate addtodate(samplingStartDate, sampleLengthDays, 'day')], ...
                [ylim(2) ylim(2)], ...
                ylim(1));
            set(gca,'Children',  [ts a]);
            set(a,  'FaceColor', 'r');
            set(a,  'LineStyle', 'none');
            
            % format
            title([waterLevel.TotalTidePort.Name, ', ', waterLevel.TotalTidePort.Country, ' (', num2str(waterLevel.TotalTidePort.Latitude), ', ', num2str(waterLevel.TotalTidePort.Longitude), ')']);
            ylabel('Height above OS Datum (m)');
            adjustAxes; 
        end
        
    end
    
    methods
        function port = getTotalTidePort(TS)
            % Returns the nearest TotalTide port to the RCM location.
            %
            % Requires the +TotalTide package and for the .Easting and 
            % .Northing properties to be set on the TimeSeries instance.            
            
            
            RCM.TimeSeries.TotalTide.isPackageAvailable;

            % Ensure the easting and northing are available
            if isempty(TS.Easting) || isempty(TS.Northing)
                errName = 'RCM:TimeSeries:MissingGeoReference';
                errDesc = 'Cannot locate TotalTide port. No easting or northing set for TimeSeries record.';
                err = MException(errName, errDesc);

                throw(err)
            end

            TS.TotalTidePort = TotalTide.closestPort(TS.Easting, TS.Northing, 'format', 'OSGB');
            
            port = TS.TotalTidePort;
        end
        
        function distance = distanceToTotalTidePort(TS)
            distance = RCM.Utils.greatCircleDistance([TS.Latitude, TS.Longitude], [TS.TotalTidePort.Latitude, TS.TotalTidePort.Longitude]);
        end
        
        function heights = totalTideWaterLevels(TS, varargin)
            % Returns the tidal heights at the nearest TotalTide port
            % location for the period specified by *offset* and *length*.
            %
            % *offset* represents the start date of the TotalTide water
            % levels relative to the RCM timeseries start date. Negative values 
            % indicate a start date (in days) *before* the RCM sampling period 
            % while positive values indicate a number of days *after*.
            %
            % *length* represents the number of days required for the
            % TotalTide water level record.
            %
            % 
            % Optional arguments can be used.
            %
            % The default resolution is 60 minutes.
            %
            % An accompanying plot is also generated which highlights the
            % sampling period in the context of the annual tidal
            % variability. This feature can be suppressed by setting the 'plot' 
            % option to 0, e.g.,
            %
            %  heights = ts.totalTideWaterLevels(..., 'plot', 0)
            %
            % Usage:
            %
            %   heights = ts.totalTideWaterLevels(offset, length, varargin)
            %

            plot       = 1;
            offsetDays = 0;
            lengthDays = TS.lengthDays;
            
            if ~isempty(varargin)
                for i = 1:2:size(varargin,2) 
                    switch varargin{i}
                      case 'plot'
                        plot = varargin{i + 1};
                      case 'offsetDays'
                        offsetDays = varargin{i + 1};
                      case 'lengthDays'
                        lengthDays = varargin{i + 1};
                    end
                end   
            end
            
            varargin{end+1} = 'easting';
            varargin{end+1} = TS.Easting;
            varargin{end+1} = 'northing';
            varargin{end+1} = TS.Northing;
            varargin{end+1} = 'latitude';
            varargin{end+1} = TS.Latitude;
            varargin{end+1} = 'longitude';
            varargin{end+1} = TS.Longitude;
            
            contextStartDate  = addtodate(TS.startTime, offsetDays, 'day');
            
            heights = RCM.WaterLevel.TimeSeries.fromTotalTide(contextStartDate, ...
                lengthDays, ...
                varargin{:});
            
            % Now generate a plot if appropriate
            
            if plot
                RCM.TimeSeries.TotalTide.contextPlot(heights, ...
                    TS.startTime, ...
                    round(TS.lengthDays));
            end
        end
        
        function heights = totalTideYear(TS,varargin)
            % Returns the tidal heights at the nearest TotalTide port
            % locations for the annual period around the current timeseries
            % dataset. 
            % 
            
            varargin{end+1} = 'offsetDays';
            varargin{end+1} =  -175; % 175 makes the 15 day period roughly central
            varargin{end+1} = 'lengthDays';
            varargin{end+1} = 365;  % Plot a time period of 1 year
           
            heights = TS.totalTideWaterLevels(varargin{:});
        end
    end
    
end

