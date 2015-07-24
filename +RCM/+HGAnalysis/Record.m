classdef Record < RCM.Current.TimeSeries & handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   Record.m  $
% $Revision:   1.4  $
% $Author:   andrew.berkeley  $
% $Date:   Jul 31 2014 12:32:04  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Class for representing and manipulating current timeseries data - specifically
    % data arising out of the HGAnalysis spreadsheet template.
    %
    % This class is a subclass of RCM.TimeSeries and inherits all of the
    % behaviour of that class and adds some additional functionality.
    %
    % Usage:
    %
    %    R = RCM.HGAnalysis.Record(dateTime, speed, direction);
    %
    % where dateTime, speed, direction are vectors describing the time (as
    %       datenums), speed and direction of currents
    % 
    %
    % EXAMPLES:
    %
    %   currents = RCM.HGAnalysis.Record(dateTime, speed, direction)
    %   currents.SiteName = 'Geasgill'
    %   currents.SiteCode = 'FFMC77'
    %   currents.PercentLessThan3cm
    %   ans =
    %       28.9
    %   currents.PercentLessThan9_5cm
    %   ans =
    %       79.1
    %
    % DEPENDENCIES:
    %
    % - +RCM/TimeSeries.m
    % - +RCM/+HGAnalysis/import.m
    %
    
    properties
        DataType      = '';
        Filename      = '';
        SiteName      = '';
        ShortFileName = '';
        Path          = '';
        SiteID        = '';
        
        PercentLessThan3cm   = NaN;
        PercentLessThan9_5cm = NaN;
        
        DataIntervalMinutes = 20;
    end
    
    methods (Static = true)
        
        function [r] = fromExcel(path,rowLimit)
            % Instantiate an instance of RCM.HGAnalysis.Record from an
            % HGAnalysis spreadsheet file.
            %
            % Usage:
            %
            %  record = RCM.HGAnalysis.Record.fromExcel(path)
            %
            
            if exist('rowLimit', 'var')
                data = RCM.HGAnalysis.import(path, rowLimit);
            else
                data = RCM.HGAnalysis.import(path);  
            end
            
            r = RCM.HGAnalysis.Record();
            
            r.Time = data.DateTime;
            r.Speed = data.Speed;
            r.Direction = data.Direction;
            
            r.Pressure       = data.Pressure;
            r.Easting        = data.Easting;
            r.Northing       = data.Northing;
            r.DataType       = data.DataType;
            r.Filename       = data.Filename;
           
            slashPos=regexp(path,'\\');
            if isempty(slashPos)
                error('Please include path with filename');
            end

            % Short filename
            r.ShortFileName=path((max(slashPos)+1):end);
            r.Path=path(1:max(slashPos));
        end
         
    end
    
    methods
        function R = Record()
            % Constructor method
                        
            R = R@RCM.Current.TimeSeries();           
        end
        
        function plt3 = get.PercentLessThan3cm(R)
            if isempty(R.PercentLessThan3cm) || isnan(R.PercentLessThan3cm)
                R.PercentLessThan3cm = R.percentLessThan(0.03);
            end
            
            plt3 = R.PercentLessThan3cm;
        end
        
        function plt9_5 = get.PercentLessThan9_5cm(R)
            if isempty(R.PercentLessThan9_5cm) || isnan(R.PercentLessThan9_5cm)
                R.PercentLessThan9_5cm = R.percentLessThan(0.095);
            end
            
            plt9_5 = R.PercentLessThan9_5cm;
        end
        
        function scatterPlot(R)
            % Generates a scatterplot of the current vectors
            
            scatterPlot@RCM.Current.TimeSeries(R, R.SiteName, num2str(R.HeightAboveBed));
        end
        
        function normalisedScatterPlot(R)
            % Generates a scatterplot of the current vectors normalised in
            % the direction of the major axis
            
            normalisedScatterPlot@RCM.Current.TimeSeries(R, R.SiteName, num2str(R.HeightAboveBed));
        end
        
        function timeSeriesPlot(R)
            % Generates timeseries subplots of the water depth and current
            % speeds/direction
            
            timeSeriesPlot@RCM.Current.TimeSeries(R, R.SiteName, num2str(R.HeightAboveBed));
        end
        
    end
    
end

