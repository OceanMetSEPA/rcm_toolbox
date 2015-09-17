function [fit1, rSq1, fit2, rSq2] = fitProperty2TidalRange(currentTS, waterLevelTS, varargin)

    % 'plot': 0, 1
    % 'tidalOnly': 0, 1:
    % 'splitPhases': 0, 1

    fit1 = [];
    rSq1 = NaN;
    fit2 = [];
    rSq2 = NaN;

    generatePlot = 0;            
    splitPhases  = 0;
    metric       = 'mean';
    property     = 'Speed';

    if ~isempty(varargin)
        for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
            switch varargin{i}
              case 'plot'
                generatePlot = varargin{i + 1};
              case 'splitPhases'
                splitPhases = varargin{i + 1};
              case 'metric'
                metric = varargin{i + 1};
              case 'property'
                property = varargin{i + 1};
            end
        end   
    end

    tidalRanges              = waterLevelTS.ranges; 
    tidalPhasePropertyMetric = currentTS.tidalPhaseStat(property, metric);

    % Tidal ranges may have NaN values at the start and end. Clear
    % these if so.
    nanRanges = isnan(tidalRanges);
    tidalRanges(nanRanges)              = [];
    tidalPhasePropertyMetric(nanRanges) = [];

    if splitPhases
        % Define linear fit
        floodIndexes = tidalRanges > 0;
        ebbIndexes = tidalRanges < 0;

        fit1 = polyfit(abs(tidalRanges(floodIndexes)), tidalPhasePropertyMetric(floodIndexes),1);
        fit2 = polyfit(abs(tidalRanges(ebbIndexes)), tidalPhasePropertyMetric(ebbIndexes),1);

        model1 = polyval(fit1, abs(tidalRanges(floodIndexes)));
        model2 = polyval(fit2, abs(tidalRanges(ebbIndexes)));

        rSq1 = RCM.Utils.rSquared(tidalPhasePropertyMetric(floodIndexes), model1);
        rSq2 = RCM.Utils.rSquared(tidalPhasePropertyMetric(ebbIndexes), model2);
    else
        fit1 = polyfit(abs(tidalRanges), tidalPhasePropertyMetric,1);
        model = polyval(fit1, abs(tidalRanges));

        % Calculate the R2 value  - a measure of the model fit
        rSq1 = RCM.Utils.rSquared(tidalPhasePropertyMetric, model);
    end

    if generatePlot

        figure;
        plot(abs(tidalRanges), tidalPhasePropertyMetric, '.r');
        xlim([0 max(abs(tidalRanges))]);
        ylim([0 max(tidalPhasePropertyMetric)]);
        grid on;
        title(['Tidal range versus ', property])
        xlabel('Tidal range (m)');

        ylabel([metric,' ', property]);

        hold on;

        if splitPhases
            % Plot the model line through the data
            floodModel = polyval(fit1, [0 max(abs(tidalRanges(floodIndexes)))]);
            plot([0 max(abs(tidalRanges(floodIndexes)))], floodModel);

            ebbModel = polyval(fit2, [0 max(abs(tidalRanges(ebbIndexes)))]);
            plot([0 max(abs(tidalRanges(ebbIndexes)))], ebbModel);

            % Annotate with model equation and fit measure
            caption1 = ['y1 = ', num2str(fit1(1)), ' * x + ', num2str(fit1(2)), '; R2 = ', num2str(rSq1)];
            text(0.1,max(tidalPhasePropertyMetric)*0.95, caption1);
            caption2 = ['y2 = ', num2str(fit2(1)), ' * x + ', num2str(fit2(2)), '; R2 = ', num2str(rSq2)];
            text(0.1,max(tidalPhasePropertyMetric)*0.9, caption2);
        else
            % Plot the model line through the data
            model = polyval(fit1, [0 max(abs(tidalRanges))]);
            plot([0 max(abs(tidalRanges))], model);

            % Annotate with model equation and fit measure
            caption = ['y = ', num2str(fit1(1)), ' * x + ', num2str(fit1(2)), '; R2 = ', num2str(rSq1)];
            text(0.1,max(tidalPhasePropertyMetric)-0.01, caption);
        end

    end

end