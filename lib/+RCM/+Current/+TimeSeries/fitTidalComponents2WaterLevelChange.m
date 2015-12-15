function [uFitF, vFitF, uFitE, vFitE] = fitTidalComponents2WaterLevelChange(currentTS, waterLevelTS, varargin)

    % 'plot': 0, 1
    % 'tidalOnly': 0, 1:
    % 'splitPhases': 0, 1

    uFitF = [];
    vFitF = [];
    uFitE = [];
    vFitE = [];

    generatePlot = 0;  
    nonTidal     = 0;

    if ~isempty(varargin)
        for i = 1:2:size(varargin,2) % only bother with odd arguments, i.e. the labels
            switch varargin{i}
              case 'plot'
                generatePlot = varargin{i + 1};
              case 'nonTidal'
                nonTidal = varargin{i + 1};
            end
        end   
    end

    levelChanges = waterLevelTS.gradient; % central difference
    
    tidalU = currentTS.uTidal;
    tidalV = currentTS.vTidal;
    
    if nonTidal
        tidalU = tidalU.*(-1) + currentTS.u;
        tidalV = tidalV.*(-1) + currentTS.v;
    end
    
    % Define linear fit
    floodIndexes = levelChanges > 0;
    ebbIndexes   = levelChanges < 0;

    uFitF = polyfit(levelChanges(floodIndexes), tidalU(floodIndexes),1);
    uFitE = polyfit(levelChanges(ebbIndexes), tidalU(ebbIndexes),1);
    vFitF = polyfit(levelChanges(floodIndexes), tidalV(floodIndexes),1);
    vFitE = polyfit(levelChanges(ebbIndexes), tidalV(ebbIndexes),1);

    uModelF = polyval(uFitF, levelChanges(floodIndexes));
    uModelE = polyval(uFitE, levelChanges(ebbIndexes));
    vModelF = polyval(vFitF, levelChanges(floodIndexes));
    vModelE = polyval(vFitE, levelChanges(ebbIndexes));

    uRSqF = RCM.Utils.rSquared(tidalU(floodIndexes), uModelF);
    uRSqE = RCM.Utils.rSquared(tidalU(ebbIndexes), uModelE);
    vRSqF = RCM.Utils.rSquared(tidalV(floodIndexes), vModelF);
    vRSqE = RCM.Utils.rSquared(tidalV(ebbIndexes), vModelE);
    
    if generatePlot

        figure;
        subplot(211)
        plot(levelChanges, tidalU, '.r');
        xlim([min(levelChanges) max(levelChanges)]);
        ylim([min(tidalU) max(tidalU)]);
        grid on;
        title('Tidal elevation change versus velocity')
        xlabel('Tidal elevation change (m)');

        ylabel('U');

        hold on;

        % Plot the model line through the data
        uModelF = polyval(uFitF, [min(levelChanges(floodIndexes))*1.5 max(levelChanges(floodIndexes))*1.5]);
        plot([min(levelChanges(floodIndexes))*1.5 max(levelChanges(floodIndexes))*1.5], uModelF);

        uModelE = polyval(uFitE, [min(levelChanges(ebbIndexes))*1.5 max(levelChanges(ebbIndexes))*1.5]);
        plot([min(levelChanges(ebbIndexes))*1.5 max(levelChanges(ebbIndexes))*1.5], uModelE);

        % Annotate with model equation and fit measure
        caption1 = ['y1 = ', num2str(uFitF(1)), ' * x + ', num2str(uFitF(2)), '; R2 = ', num2str(uRSqF)];
        text(min(levelChanges(ebbIndexes)), max(tidalU)*0.8, caption1);
        caption1 = ['y1 = ', num2str(uFitE(1)), ' * x + ', num2str(uFitE(2)), '; R2 = ', num2str(uRSqE)];
        text(min(levelChanges(ebbIndexes)), max(tidalU)*0.6, caption1);
        
        subplot(212)
        
        plot(levelChanges, tidalV, '.r');
        xlim([min(levelChanges) max(levelChanges)]);
        ylim([min(tidalV) max(tidalV)]);
        grid on;
        title('Tidal elevation change versus velocity')
        xlabel('Tidal elevation change (m)');

        ylabel('V');

        hold on;
        
        % Plot the model line through the data
        vModelF = polyval(vFitF, [min(levelChanges(floodIndexes))*1.5 max(levelChanges(floodIndexes))*1.5]);
        plot([min(levelChanges(floodIndexes))*1.5 max(levelChanges(floodIndexes))*1.5], vModelF);

        vModelE = polyval(vFitE, [min(levelChanges(ebbIndexes))*1.5 max(levelChanges(ebbIndexes))*1.5]);
        plot([min(levelChanges(ebbIndexes))*1.5 max(levelChanges(ebbIndexes))*1.5], vModelE);

        % Annotate with model equation and fit measure
        caption1 = ['y1 = ', num2str(vFitF(1)), ' * x + ', num2str(vFitF(2)), '; R2 = ', num2str(vRSqF)];
        text(min(levelChanges(ebbIndexes)), min(tidalV)*0.8, caption1);
        caption1 = ['y1 = ', num2str(vFitE(1)), ' * x + ', num2str(vFitE(2)), '; R2 = ', num2str(vRSqE)];
        text(min(levelChanges(ebbIndexes)), min(tidalV)*0.6, caption1);
        

    end

end