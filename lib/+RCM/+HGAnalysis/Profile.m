classdef Profile < RCM.Current.Profile 
    % Class for representing and manipulating current profile data based around
    % 3 x HGAnalysis worsheets.
    %
    % Instances are created by passing in references to 3 HGAnalysis sheets
    % representing 'surface', 'middle' and 'bottom' currents, as well as other 
    % optional data. Easting and northing data are required to support
    % harmonic analysis and other functionality. These are usually
    % found in the HGAnalsysis sheet automatically and so do not need
    % to be explcitly set. Sometimes they are missing though, in which case
    % they need to be passed explcitly into the contructor function.
    %
    % This class inherits and extends the more general RCM.Profile class.
    % The convenience functions .Surface, .Middle, and .Bottom provide
    % intuitive access to the 3 depth level records.
    %
    %  
    % Usage:
    %
    %    profile = RCM.HGAnalysis.Profile.fromExcel(varargin);
    %
    %
    % EXAMPLES:
    %
    %    s    = 'C:\...\...\Geasgill surface HGdata_analysis_v7.xls';
    %    m    = 'C:\...\...\Geasgill mid HGdata_analysis_v7.xls';
    %    b    = 'C:\...\...\Geasgill bed HGdata_analysis_v7.xls';
    %    name = 'Geasgill';
    %
    %    profile = RCM.HGAnalysis.Profile.fromExcel('surface', s, 'middle', m, 'bottom', b, 'SiteName', name);
    %
    %      *Profile* with properties:
    % 
    %         Surface: [1x1 RCM.HGAnalysis.Record]
    %          Middle: [1x1 RCM.HGAnalysis.Record]
    %          Bottom: [1x1 RCM.HGAnalysis.Record]
    %            Bins: {3x1 cell}
    %         Easting: 143657
    %        Northing: 737678
    %
    %  If the easting and northings turn out to be unavailable then these
    %  need to be passed in explicitly
    %
    %    profile = RCM.HGAnalysis.Profile.fromExcel(..., 'Easting', 123456, 'Northing', 987654);
    %
    %  Other data can be passed in to the constructor method or set after initialization
    %  E.g.
    %
    %    profile = RCM.HGAnalysis.Profile.fromExcel(...
    %       'surface', s,...
    %       'middle', m,...
    %       'bottom', b,...
    %       'SiteName', name,...
    %       'SiteID', 'GEAS1',...
    %       'SurfaceHeightAboveBed', 45.5,...
    %       'MiddleHeightAboveBed', 32.5,...
    %       'BottomHeightAboveBed', 2.5...
    %    );
    %
    %  Or,
    %
    %    profile = RCM.HGAnalysis.Profile.fromExcel(...
    %       'surface', s,...
    %       'middle', m,...
    %       'bottom', b...
    %    );
    %
    %    profile.SiteName = 'Geasgill';
    %    profile.Surface.HeightAboveBed = 45.5;
    %    profile.Middle.HeightAboveBed = 32.5;
    %    profile.Bottom.HeightAboveBed = 2.5;
    % 
    %
    % DEPENDENCIES:
    %
    % - +RCM/Profile.m
    % - +RCM/+HGAnalysis/Record.m
    %
    
    methods (Static = true)
        
        function profile = fromExcel(varargin)
            % Constructor method for building a Profile instance from 3 x
            % HGAnalysis spreadsheet files.
            %
            % Usage:
            %
            %    profile = RCM.HGAnalysis.Profile.fromExcel(varargin);
            %
            %
            % EXAMPLES:
            %
            %    s    = 'C:\...\...\Geasgill surface HGdata_analysis_v7.xls';
            %    m    = 'C:\...\...\Geasgill mid HGdata_analysis_v7.xls';
            %    b    = 'C:\...\...\Geasgill bed HGdata_analysis_v7.xls';
            %    name = 'Geasgill';
            %
            %    profile = RCM.HGAnalysis.Profile.fromExcel('surface', s, 'middle', m, 'bottom', b, 'SiteName', name);
            %
            %      *Profile* with properties:
            % 
            %         Surface: [1x1 RCM.HGAnalysis.Record]
            %          Middle: [1x1 RCM.HGAnalysis.Record]
            %          Bottom: [1x1 RCM.HGAnalysis.Record]
            %         Easting: 143657
            %        Northing: 737678
            %
            %  If the easting and northings turn out to be unavailable then these
            %  can be passed in explicitly
            %
            %    profile = RCM.HGAnalysis.Profile.fromExcel(..., 'Easting', 123456, 'Northing', 987654);
            %
            %  or, set after initialization
            %
            %    profile.Easting = 123456
            %    profile.Northing = 987654
            
            % Find the rowLimit argument if it exists as this needs to be handled
            % specifically
            rowLimitArgIndex = find(strcmpi(varargin,'rowLimit'));

            if isempty(rowLimitArgIndex)
                rowLimit = '1089'; % default
            else
                rowLimit = varargin{rowLimitArgIndex + 1};
            end 
            
            profile = RCM.HGAnalysis.Profile(varargin{:});
                        
            % Process data first, so they are in place for any additional
            % actions
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'Bottom'
                  profile.Bins{1,1} = RCM.HGAnalysis.Record.fromExcel(varargin{i+1}, rowLimit);
                case 'Middle'
                  profile.Bins{2,1} = RCM.HGAnalysis.Record.fromExcel(varargin{i+1}, rowLimit);
                case 'Surface'
                  profile.Bins{3,1} = RCM.HGAnalysis.Record.fromExcel(varargin{i+1}, rowLimit);
              end
            end
            
            % In the case that no middle bin is provided
            profile.removeEmptyBins
                        
            % Parse and handle any HGAnalysis.Profile-specific arguments
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'SurfaceHeightAboveBed'
                  profile.Surface.HeightAboveBed = varargin{i+1};
                case 'MiddleHeightAboveBed'
                  profile.Middle.HeightAboveBed = varargin{i+1};
                case 'BottomHeightAboveBed'
                  profile.Bottom.HeightAboveBed = varargin{i+1};
              end
            end
            
            % Run the tidal harmonic analysis on each bin.
            profile.calculateHarmonics;
            
            % Make sure that these attributes are consistent between the
            % parent profile object and its timeseries record children.
            profile.syncAttribute('Easting')
            profile.syncAttribute('Northing');
            profile.syncAttribute('SiteName');
            profile.syncAttribute('SiteID');
        end
    end
    
    properties
        Surface = [];
        Middle = [];
        Bottom = [];
    end
    
    methods
        function P = Profile(varargin)
            % Constructor method
            
            P = P@RCM.Current.Profile(varargin{:});
        end
        
        function set.Surface(P, ts)
            % Convenience method for setting the surface bin. The passed in
            % object should be an instance of RCM.HGAnalysis.Record.
            
            if P.size < 2
                P.Bins{2,1} = ts;
            else
                P.Bins{3,1} = ts;
            end
        end
        
        function set.Middle(P, ts)
            % Convenience method for setting the middle bin. The passed in
            % object should be an instance of RCM.HGAnalysis.Record.
            
           if P.size == 2
               P.Bins{3,1} = P.Bins{2,1};
           end
           P.Bins{2,1} = ts;
        end
        
        function set.Bottom(P, ts)
            % Convenience method for setting the bottom bin. The passed in
            % object should be an instance of RCM.HGAnalysis.Record.
            
            P.Bins{1} = ts;
        end    
        
        function s = get.Surface(P)
            % Convenience method for accessing the 'surface' bin. If more
            % than 1 bin exists, this method returns the last bin from the Bins 
            % property, assumed to represent the most shallow bin. Otherwise, an 
            % empty vector is returned (a single bin would be assumed to represent 
            % the bottom bin rather than the surface bin).
            
            if P.size == 1
                s = [];
            else
                s = P.Bins{end};
            end
        end
        
        function m = get.Middle(P)
            % Convenience method for accessing the 'middle' bin. If only 2
            % bins exist, this method returns an empty vector as there is no
            % 'middle bin'. Otherwise, the bin at index 2 is returned. This
            % supports cases where only a 'bottom' and 'surface' record are
            % used.
            
            if P.size == 2
                m = [];
            else
                m = P.Bins{2,1};
            end
        end
        
        function b = get.Bottom(P)
            % Convenience method for accessing the 'bottom' bin. This method 
            % returns the first bin in the Bins property.
            
            b = P.Bins{1};
        end
        
        function speedAndDirectionTimeSeries(P)    
            % Generates a time series plot showing the magnitudes and
            % directions for each depth bin on the profile. Raw and 
            % harmonically reconstructed data is shown on all plots.
            
            speedAndDirectionTimeSeries@RCM.Current.Profile(P, P.validBinIndexes);
        end   
        
        function [str] = toArchiveStruct(P)
            % Returns a struct representation of the object with the names
            % of some fields changed to be consistent with OceanMet archive
            % conventions
            
            str = toArchiveStruct@RCM.Current.Profile(P);
            str = rmfield(str, 'Bins');
            
            str.Surface = str.Surface.toArchiveStruct;
            str.Middle = str.Middle.toArchiveStruct;
            str.Bottom = str.Bottom.toArchiveStruct;
        end

    end

end

