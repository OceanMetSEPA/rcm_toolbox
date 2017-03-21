classdef Tide
    
    properties (Constant = true)
        SpringNeapAverageDays           = 14.77;
        SpringNeapAverageSeconds        = 14.77 * 24 * 60 * 60;
        SemiDiurnalHalfCycleSeconds     = 22350;
        
        % Since the average period of a semi-diurnal tidal cycle is 12 h 25 m 
        % we get 28.54.. cycles in a spring-neap cycle:
        %
        %   14.77*(24/(12 + 25/60)) = 28.5457248 
        % 
        % So there are twenty-eight and a half semi-diurnal cycles in an 
        % average spring-neap cycle.
        SemiDiurnalHalfCycleSecondsPerSpringNeap  = 28.5487248322148;
        
        % This is the factor by which the final (57th) semi-diurnal half-cycle of
        % a spring neap cycle needs to be extended in order to match the
        % average length of a spring neap cycle.
        SemiDiurnalHalfCycleSpringNeapExcessFactor = 1.0974496644295; % Jesus!
    end
    
end

