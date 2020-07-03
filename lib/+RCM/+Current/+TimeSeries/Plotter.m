classdef (Abstract) Plotter < handle
    % Mixin class to be used with RCM.Current.TimeSeries
    
    methods(Static = true)
        function h = componentScatterPlot(u, v, varargin)
            % Generalised function for producing a 2D scatterplot of
            % vectors based on the components u and v.
            %
            % Additional options can be specified to add a line describing
            % the major axis as well as defining the title and legend.
            %
            % Usage:
            %
            %  RCM.TimeSeries.componentsScatterPlot(u, v, varargin)
            %
            % Examples:
            %
            %  RCM.TimeSeries.componentsScatterPlot(u, v)
            %  RCM.TimeSeries.componentsScatterPlot(u, v, 'majorAxis', 271)
            %  RCM.TimeSeries.componentsScatterPlot(u, v, 'title', 'Geasgill currents - 2.65 m above bed', 'majorAxis', 271)
            %  RCM.TimeSeries.componentsScatterPlot(u, v, 'legend', struct('A', 'raw data', 'B', 'major axis'))
            %

            % Perhaps abstract out the legend, title, etc stuff so  that
            % more complex plot methods can be defined (e.g. combined
            % scatterplot)

            majorAxis   = NaN;
            chartTitle  = [];
            chartLegend = [];

            for i = 1:2:length(varargin)
              switch varargin{i}
                case 'majorAxis'
                  majorAxis = varargin{i + 1};
                case 'title'
                  chartTitle = varargin{i + 1};
                case 'legend'
                  chartLegend = varargin{i + 1};
              end
            end    

            minA = min([min(u) min(v)]);  % min of plot area
            maxA = max([max(u) max(v)]);  % max of plot area
            absA = max([abs(minA) maxA]); % maximum absolute value, to determine the major axis line length

            h = figure; 
            plot(u, v, '.r');
            grid on; 
            hold on;

            % Centroid of data cloud
            plot(mean(u), mean(v), 'k+');

            if ~isnan(majorAxis)
                [eastCheck, northCheck]=RCM.Utils.spd2uv(absA, majorAxis);
                line([0 eastCheck], [0 northCheck]);
                clear eastCheck northCheck;
                legend(chartLegend.A, 'Centre', chartLegend.B);
            else
                legend(chartLegend.A, 'Centre');
            end

            if ~isempty(chartTitle)
                title(chartTitle);
            end

            plot([0 0],[-absA absA],'--k');
            plot([-absA absA],[0 0],'--k');
            hold off;
        end
    end
    
    methods
        function h = scatterPlot(TS)
            % Generates a scatterplot of the current vectors
            
            legend = struct('A', 'raw data', 'B', 'major axis');
            h = RCM.Current.TimeSeries.componentScatterPlot(TS.u, TS.v, 'majorAxis', TS.MajorAxis, 'legend', legend);
        end
        
        function h =normalisedScatterPlot(TS, name, depth)
            % Generates a scatterplot of the current vectors normalised in
            % the direction of the major axis
            
            legend = struct('A', 'rotated. data');
            h = RCM.Current.TimeSeries.componentScatterPlot(TS.NormalComponent, TS.ParallelComponent, 'title', [name,', normalised currents - ', depth, ' m above bed'], 'legend', legend);
        end
        
        function h = cumulativeVectorPlot(TS)
            % Generates a plot of the cumulative vector
            
            cumVec = TS.cumulativeVector;
            h = figure; 
            plot(cumVec(:,1), cumVec(:,2));
            grid on;
        end
              
        function h = timeSeriesPlot(TS)
            % Generates a time series plot describing the water level,
            % current speeds and directions
            
            h = figure;
            subplot(311);
            plot(TS.Time, TS.Pressure);
            grid on;
            set(gca, 'XTick', TS.Time(ceil(linspace(1,size(TS.Time,1),5))));
            set(gca, 'XTickLabel', datestr(TS.Time(ceil(linspace(1,size(TS.Time,1),5))),20));
            xlabel('Date');
            ylabel('Water level (m)');

            subplot(312);
            plot(TS.Time, TS.Speed);
            grid on;
            hold on;
            set(gca, 'XTick', TS.Time(ceil(linspace(1,size(TS.Time,1),5))));
            set(gca, 'XTickLabel', datestr(TS.Time(ceil(linspace(1,size(TS.Time,1),5))),20));
            xlabel('Date');
            ylabel('Current speed (m/s)');

            subplot(313);
            plot(TS.Time, TS.Direction);
            grid on;
            set(gca, 'XTick', TS.Time(ceil(linspace(1,size(TS.Time,1),5))));
            set(gca, 'XTickLabel', datestr(TS.Time(ceil(linspace(1,size(TS.Time,1),5))),20));
            xlabel('Date');
            ylabel('Current direction (deg)');
        end
        
        function h = totalTideWaterLevelPlot(TS)
            
            if isempty(TS.TotalTidePort)
                port = TS.getTotalTidePort();
            end
            
            % Here we want more detail than just the slack heights
            totalTideHeights = TS.totalTideWaterLevels('offsetDays', 0, 'lengthDays', TS.lengthDays, 'plot', 0);
            totalTideHeights.truncateByTime('startTime', TS.Time(1), 'endTime', TS.Time(end));

            h = figure;
            h(1)=subplot(2,1,1);
            plot(TS.Time, TS.Pressure, 'r');
            hold on;
            plot(totalTideHeights.Time, totalTideHeights.Height, 'b');
            title(['Sampled pressure record (red) and Total Tide water levels for ', TS.TotalTidePort().Name, ' (blue)'])
            ylabel('metres');
            grid on;

            h(2)=subplot(2,1,2);
            % plot sampled pressure record - normalize to zero mean
            plot(TS.Time, TS.Pressure - mean(TS.Pressure), 'r');
            hold on;
            % plot Total Tide levels - normalize to zero mean
            plot(totalTideHeights.Time, totalTideHeights.Height - mean(totalTideHeights.Height), 'b');
            title(['Normalized water levels. Sampled (red) and ', TS.TotalTidePort().Name, ' (blue)'])
            ylabel('metres');
            grid on;

            adjustAxes; 
        end
    end
    
end

