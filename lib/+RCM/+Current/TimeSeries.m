classdef TimeSeries < RCM.TimeSeries.TotalTide ... % Abstract classes first
        & RCM.Current.TimeSeries.Plotter ...
        & RCM.TimeSeries.Base
    
    % Class for representing and manipulating current timeseries data.
    % Instances are created by passing in three vectors representing 
    %
    %   - time
    %   - speed
    %   - direction
    %
    % The current vectors are decomposed into their constituent u and v
    % components, and stored on the .u and .v properties. A number of descriptive 
    % statistics and a harmonic analysis of the data can be easily done.
    % There are useful methods for generating plots and contextualising
    % the data using Total Tide.
    %
    % Object properties are also available for storing other commonly
    % useful data such as a corresponding presure record (.Pressure), the RCM easting 
    % (.Easting) and northing (.Northing), and the height above the sea bed
    % of the respective RCM bin (.HeightAboveBed). The class extends
    % *dynamicprops* and therefore any other properties can be added
    % arbitrarily when needed.
    %
    % Usage:
    %
    %    C = RCM.Current.TimeSeries(time, speed, direction);
    %
    % where dateTime, speed, direction are vectors describing the time (as
    %       datenums), speed and direction of currents
    % 
    %
    % EXAMPLES:
    %
    %   currents = RCM.Current.TimeSeries(timeVector, speedVector, directionVector)
    %   currents.Time
    %     ans =
    %               735168.477083333
    %               735168.490972222
    %               735168.504861111
    %               ...
    %
    %   currents.Speed
    %     ans =
    %               0.0467
    %               0.1099
    %               0.0548
    %               ...
    %
    %   currents.Direction
    %     ans =
    %               212.75
    %               171.83
    %               108.27
    %               ...
    %  
    %   currents.u
    %     ans =
    %            -0.0252635078128853
    %             0.0156179624742282
    %             0.0520375184947972
    %             ...
    %
    %   currents.v
    %     ans =
    %            -0.0392765219054371
    %             -0.108784600234379
    %            -0.0171795421622242
    %             ...
    %
    %      
    %  ## Statistics ##
    %
    %  Summary statistics are generated which can be accessed via the following fields
    %
    %   currents.MeanSpeed
    %   currents.MajorAxis
    %   currents.ParallelAmplitude
    %   currents.NormalAmplitude
    %   currents.AmplitudeAnisotropy
    %   currents.ResidualSpeed
    %   currents.ResidualDirection
    %
    %  Some other derivations from the data can be accessed using these
    %  methods:
    %
    %   currents.percentLessThan()
    %   currents.normalisedComponents()
    %   currents.cumulativeVector()
    %
    %  ## Harmonics ##
    %
    %  A harmonic analysis can be generated by running the following
    %  method
    %
    %   currents.calculateHarmonics() 
    %   
    %  and the results can be accessed via the following fields
    %
    %   currents.TideCoefficients
    %   currents.TideReconstructedComponents
    %   currents.uTidal
    %   currents.vTidal
    %   currents.uNonTidal
    %   currents.vNonTidal
    %   currents.SpeedTidal
    %   currents.DirectionTidal
    %   currents.Tideyness
    %
    %  NOTE: harmonic analysis requires a latitude, which needs to be set
    %  using either the .Latitude property explicity or by setting the 
    %  .Easting and .Northing properties.
    %
    %  ## Plots ##
    %
    %  A number of standard plots can be easily generated using the
    %  following methods
    %   
    %   currents.scatterPlot
    %   currents.normalisedScatterPlot
    %   currents.cumulativeVectorPlot
    %
    %
    % DEPENDENCIES:
    %
    % - UTide
    % - +TotalTide/
    % - +RCM/+Utils
    % - OS.catCoordinates.m
    % - greatCircleDistance.m
    %
    
    properties (SetAccess = public, GetAccess = public)  
        % required for instantiation
        Speed double     = [];
        Direction double = [];
        
        % optional
        Pressure double = [];
        HeightAboveBed = NaN;
        
        % Components - derived
        u double = [];
        v double = [];
        ParallelComponent double = [];
        NormalComponent double   = [];
        
        % Stats - derived
        MeanSpeed double            = NaN;
        MajorAxis double            = NaN;
        ParallelAmplitude double    = NaN;
        NormalAmplitude double      = NaN;
        AmplitudeAnisotropy double  = NaN;
        ResidualSpeed double        = NaN;
        ResidualDirection double    = NaN;
        
        ResidualConsistentMajorAxis double = NaN;
        ResidualMajorAxisAngle double      = NaN;
        
        % Tide - derived
        TideCoefficients = [];
        uTidal double          = [];
        vTidal double          = [];
        uNonTidal double       = [];
        vNonTidal double       = [];
        SpeedTidal double      = [];
        DirectionTidal double  = [];
        SpeedNonTidal double   = [];
        DirectionNonTidal double  = [];
        Tideyness double       = NaN;
    end
    
    methods(Static = true)
        
        function TS = create(time, speed, direction, varargin)
            TS = RCM.Current.TimeSeries;
            
            TS.Time      = time;
            TS.Speed     = speed;
            TS.Direction = direction;
            
            TS.calculateComponents;
            
            for a = 1:2:length(varargin)
              try
                  TS.(varargin{a}) = varargin{a + 1};
              catch
                  warning([varargin{a}, ' is not a valid property'])
              end
            end
        end
        
        function TS = createFromComponents(time, u, v, varargin)
            TS = RCM.Current.TimeSeries;
            
            TS.Time = time;
            TS.u    = u;
            TS.v    = v;
            
            TS.calculateSpeed;
            
            for a = 1:2:length(varargin)
              try
                  TS.(varargin{a}) = varargin{a + 1};
              catch
                  warning([varargin{a}, ' is not a valid property'])
              end
            end
        end
        
        function TS = fromHGAnalysisXls(path, varargin)
            startRow = [];
            endRow   = [];
            
            for a = 1:length(varargin)
                switch varargin{a}
                    case 'startRow'
                      startRow = varargin{a + 1};
                    case 'endRow'
                      endRow = varargin{a + 1};
                end
            end
            
            data = struct;
            data.Filename = path;
            data.Sheet    = 'Current Meter Data';
            data.Easting  = xlsread(data.Filename, data.Sheet, 'C1');
            data.Northing = xlsread(data.Filename, data.Sheet, 'D1');

            data.DateTime  = [];
            data.Speed     = [];
            data.Direction = [];
            data.Pressure  = [];

            [~,~,allData] = xlsread(data.Filename, data.Sheet);
            
            allData = allData(:, 1:4);
            
            % remove desired trailing rows
            if ~isempty(endRow) & endRow < size(allData,1)
                allData = allData(1:endRow, :);
            end
            
            % remove header rows
            if isempty(startRow) | startRow < 9
                % is start row 8 or 9 (different versions)?
                startRow = 8;
                try
                    datenum(allData{startRow,1},'dd/mm/yyyy HH:MM:SS');
                catch
                    startRow = 9;
                end                
            end
            
            allData = allData(startRow:end, :);            

            % remove empty rows (intended to hit empty trailing cells)
            charRows = cell2mat(cellfun(@ischar, allData(:,1), 'UniformOutput', 0));
            allData(~charRows, :) = [];            
            
            textData = allData(:,1);
            numData  = cell2mat(allData(:, 2:4));
            
            % Import Date & Time Surface
            for i=1:length(textData(:,1));
                if length(textData{i,1})==10;
                    tempString=strcat(textData{i,1},' 00:00:00');
                    data.DateTime(i)=datenum(tempString,'dd/mm/yyyy HH:MM:SS');
                else
                    data.DateTime(i)=datenum(textData{i,1},'dd/mm/yyyy HH:MM:SS');
                end 
            end

            data.DateTime  = data.DateTime'; % transpose to make consistent
            data.Speed     = numData(:,1);
            data.Direction = numData(:,2);

            [~, columns] = size(numData);
            if columns > 2
                data.Pressure  = numData(:,3);
            end
            
            TS = RCM.Current.TimeSeries.create(data.DateTime,data.Speed,data.Direction);
            
            TS.Pressure = data.Pressure;
            TS.Easting  = data.Easting;
            TS.Northing = data.Northing;
            
            for a = 1:2:length(varargin)
              try
                  TS.(varargin{a}) = varargin{a + 1};
              catch
                  warning([varargin{a}, ' is not a valid property'])
              end
            end
            
            try
                TS.calculateHarmonics
            catch Err
                warning(Err.message)
            end
        end
        
        function ts = fromStruct(s, varargin)
            ts = RCM.Current.TimeSeries.create(s.Time, s.Speed, s.Direction);

            ts.Pressure       = s.Pressure;
            ts.Easting        = s.Easting;
            ts.Northing       = s.Northing;
            ts.HeightAboveBed = s.HeightAboveBed;
            
            for a = 1:2:length(varargin)
              try
                  TS.(varargin{a}) = varargin{a + 1};
              catch
                  warning([varargin{a}, ' is not a valid property'])
              end
            end
        end
           
    end
    
    methods
        
        function u = get.u(TS)
            if isempty(TS.u) | isnan(TS.u)
                TS.calculateComponents;
            end
            
            u = TS.u;
        end
        
        function v = get.v(TS)
            if isempty(TS.v) | isnan(TS.v)
                TS.calculateComponents;
            end
            
            v = TS.v;
        end
        
        function p = percentLessThan(TS, testValue)
            % Returns the percentage of the currents which are slower than
            % the passed in speed.
            
            p = RCM.Utils.iquantile(TS.Speed, testValue);
        end
        
        function ms = get.MeanSpeed(TS)
            if isempty(TS.MeanSpeed) || isnan(TS.MeanSpeed)
                TS.MeanSpeed = mean(TS.Speed);
            end
            
            ms = TS.MeanSpeed;
        end
        
        function ma = get.MajorAxis(TS)
            if isempty(TS.MajorAxis) || isnan(TS.MajorAxis)
                % Need covariance for major axis:
                PCAParameters = RCM.Utils.PCA(TS.u, TS.v);

                f = PCAParameters.eigenVector(1,PCAParameters.cols(1));
                g = PCAParameters.eigenVector(2,PCAParameters.cols(1));

                TS.MajorAxis = atan2(f,g);

                if mean(TS.v)<0
                    TS.MajorAxis = TS.MajorAxis + pi;
                end

                TS.MajorAxis = TS.MajorAxis * 180 / pi;      % convert to degrees
                TS.MajorAxis = mod(TS.MajorAxis + 360, 360); % make sure axis is between 0 and 360
            end
            
            ma = TS.MajorAxis;
        end
        
        function pc = get.ParallelComponent(TS)
            if isempty(TS.ParallelComponent) | isnan(TS.ParallelComponent)
                TS.ParallelComponent = TS.Speed.*cosd(TS.Direction - TS.MajorAxis);
            end
            
            pc = TS.ParallelComponent;
        end
        
        function nc = get.NormalComponent(TS)
            if isempty(TS.NormalComponent) | isnan(TS.NormalComponent)
                TS.NormalComponent = TS.Speed.*sind(TS.Direction - TS.MajorAxis);
            end
            
            nc = TS.NormalComponent;
        end
        
        function pa = get.ParallelAmplitude(TS)
            if isempty(TS.ParallelAmplitude) || isnan(TS.ParallelAmplitude)
                % sqrt(2) converts RMS into amplitude
                TS.ParallelAmplitude = sqrt(2) * std(TS.ParallelComponent, 1);
            end
            
            pa = TS.ParallelAmplitude;
        end
        
        function na = get.NormalAmplitude(TS)
            if isempty(TS.NormalAmplitude) || isnan(TS.NormalAmplitude)
                % sqrt(2) converts RMS into amplitude
                TS.NormalAmplitude = sqrt(2) * std(TS.NormalComponent, 1);
            end
            
            na = TS.NormalAmplitude;
        end
        
        function aa = get.AmplitudeAnisotropy(TS)
            if isempty(TS.AmplitudeAnisotropy) || isnan(TS.AmplitudeAnisotropy)
                TS.AmplitudeAnisotropy = TS.ParallelAmplitude / TS.NormalAmplitude;
            end
            
            aa = TS.AmplitudeAnisotropy;
        end
        
        function rs = get.ResidualSpeed(TS)
            if isempty(TS.ResidualSpeed) || isnan(TS.ResidualSpeed)
                TS.ResidualSpeed = sqrt(sum(TS.u)^2+sum(TS.v)^2)/TS.length;
            end
            
            rs = TS.ResidualSpeed;
        end
        
        function rd = get.ResidualDirection(TS)
            if isempty(TS.ResidualDirection) || isnan(TS.ResidualDirection)
                rd = acosd(mean(TS.v)/TS.ResidualSpeed);

                if mean(TS.u) < 0
                    rd = 360 - rd;
                end

                TS.ResidualDirection = rd;
            end
            
            rd = TS.ResidualDirection;
        end
        
        function rcma = get.ResidualConsistentMajorAxis(TS)
            % The major axis really points in two diametrically opposite
            % directions. This function returns the direction which is
            % closest to the residual current direction
            
            if isempty(TS.ResidualConsistentMajorAxis) || isnan(TS.ResidualConsistentMajorAxis)
                absDiff = abs(TS.MajorAxis - TS.ResidualDirection);

                if absDiff > 90 && absDiff < 270
                    if TS.MajorAxis > TS.ResidualDirection
                        TS.ResidualConsistentMajorAxis = TS.MajorAxis-180;
                    else
                        TS.ResidualConsistentMajorAxis = TS.MajorAxis+180;
                    end
                else
                    TS.ResidualConsistentMajorAxis = TS.MajorAxis;
                end
            end
            
            rcma = TS.ResidualConsistentMajorAxis;                
        end
        
        function rmaa = get.ResidualMajorAxisAngle(TS)
            % Returns the angle between the major axis and the residual
            % current
            
            if isempty(TS.ResidualMajorAxisAngle) || isnan(TS.ResidualMajorAxisAngle)
                TS.ResidualMajorAxisAngle = abs(TS.ResidualConsistentMajorAxis - TS.ResidualDirection);
             
                if TS.ResidualMajorAxisAngle > 270
                    TS.ResidualMajorAxisAngle = 360 - TS.ResidualMajorAxisAngle;
                end
            end
            
            rmaa = TS.ResidualMajorAxisAngle;
        end
        
        function wl = waterLevels(TS)
            if ~isempty(TS.Pressure)
                normalisedPressure = TS.Pressure - mean(TS.Pressure);
                
                wl = RCM.WaterLevel.TimeSeries.create(TS.Time, normalisedPressure);
                
                wl.Easting   = TS.Easting;
                wl.Northing  = TS.Northing;
                wl.Latitude  = TS.Latitude;
                wl.Longitude = TS.Longitude;
            else
                error('RCM:Current:TimeSeries:InsufficientData', ...
                    'Pressure property is empty: cannot instantiate water level object.')
            end
        end
                
        function TS = calculateHarmonics(TS)
            % Generates a harmonic analysis for the current data and
            % populates the appropriate instance properties (.tideCoefficients,
            % .uTidal, .vTidal, etc.)
            
            if isnan(TS.Latitude)
                fprintf('Latitude not known. Cannot perform harmonic analysis\n')
                return
            end
            
            try
                cmd = sprintf('tideCoefficients=ut_solv(TS.Time, TS.u, TS.v,%f, ''auto'', ''ols'', ''white'', ''LinCI'', ''NoTrend'')', TS.Latitude);
                evalc(cmd); % Calling function this way suppresses text output
            catch
                fprintf('OH DEAR, tide stuff failed\n')
                tideCoefficients=[];
            end
            
            if ~isempty(tideCoefficients)
                [ut,vt] = ut_reconstr(TS.Time, tideCoefficients);
                du = TS.u - ut;
                dv = TS.v - vt;
                
                [TS.SpeedTidal,TS.DirectionTidal] = RCM.Utils.uv2spd(ut,vt);
                [TS.SpeedNonTidal,TS.DirectionNonTidal] = RCM.Utils.uv2spd(du,dv)
            
                TS.Tideyness = var(TS.SpeedTidal)/var(TS.Speed); % variance is proportional to KE
            else
                ut = [];
                vt = [];
                du = [];
                dv = [];
            end
            
            TS.TideCoefficients=tideCoefficients;
            TS.uTidal=ut;
            TS.vTidal=vt;
            TS.uNonTidal=du;
            TS.vNonTidal=dv;            
        end
                
        function [cumVec] = cumulativeVector(TS)
            % Returns cumulative vector for the entire record.
            %
            % This vector represents individual u and v components
            % multiplied by the sampling time interval and therefore
            % represents a cumulative *position* vector.
                       
            timeInterval = TS.timeIntervalSeconds;
            
            cumVec      = zeros(length(TS.u)-1, 2);
            cumVec(1,1) = TS.u(1) * timeInterval;
            cumVec(1,2) = TS.v(1) * timeInterval;
            
            for i = 2:length(TS.u)
                cumVec(i,1) = TS.u(i) * timeInterval + cumVec(i-1,1);
                cumVec(i,2) = TS.v(i) * timeInterval + cumVec(i-1,2);
            end
        end  
            
        function tps = tidalPhaseStat(TS, property, func)
            wl = TS.waterLevels;
            slackIndexes = wl.slackIndexes;
            
            % Initialize vector to store the mean value for each flood and ebb tide
            tps = zeros(size(slackIndexes,1)+1,1);

            tps(1) = eval([func,'(TS.(property)(1:slackIndexes(1)))']);
            
            for i = 1:size(slackIndexes,1)-1
                tps(i+1) = eval([func,'(TS.(property)(slackIndexes(i):slackIndexes(i+1)))']);
            end
            
            tps(end) = eval([func,'(TS.(property)(slackIndexes(end):end))']);
        end      
        
        function tpm = tidalPhaseMean(TS, property)
            tpm = tidalPhaseStat(TS, property, 'mean');
        end
        
        function tpm = tidalPhaseMax(TS, property)
            tpm = tidalPhaseStat(TS, property, 'max');
        end
        
        function tpm = tidalPhaseMin(TS, property)
            tpm = tidalPhaseStat(TS, property, 'min');
        end
        
        function tpm = tidalPhaseStd(TS, property)
            tpm = tidalPhaseStat(TS, property, 'std');
        end
         
        function [str] = toStruct(TS)
            % Returns a struct representation of the object.
            
            str = struct(TS);
        end
        
        function calculateComponents(TS)
            [TS.u, TS.v] = RCM.Utils.spd2uv(TS.Speed, TS.Direction);
        end
        
        function calculateSpeed(TS)
            [TS.Speed,TS.Direction] = RCM.Utils.uv2spd(TS.u,TS.v); 
        end
    end
    
end

