classdef Profile < dynamicprops 
    % Class for representing and manipulating current meter data. This class
    % groups together multiple instances of the RCM.TimeSeries class which
    % represent current timeseries records at individual depths, forming a vertical
    % profile of current data. 
    %
    % Instances of this class provide a convenient data structure for storing 
    % and manipulating current profile data, and some useful methods for producing 
    % plots. The class extends *dynamicprops* and therefore any other properties 
    % can be added arbitrarily when needed.
    %
    % Individual bins (as RCM.TimeSeries objects) can be added to the profile
    % after instantiation using the .addBin() method. This assumes bins are
    % added from the bed upwards.
    %
    %  
    % Usage:
    %
    %    profile = RCM.Profile(varargin);
    %
    %
    % EXAMPLES:
    %
    %    profile = RCM.Profile('SiteName', 'A site', 'Easting', 123456,
    %    'Northing', 987654);
    %
    %    profile.addBin(timeseries1);
    %    profile.addBin(timeseries2);
    %    ...
    % 
    %
    % DEPENDENCIES:
    %
    % - +RCM/TimeSeries.m
    %
    
    properties
        Bins = {};
        SiteName = [];
        SiteID   = [];
        Easting  = NaN;
        Northing = NaN;
        WaterDepth = NaN;
    end
    
    properties (Hidden = true)
    end
    
    methods (Static = true)
    end
    
    methods
        function P = Profile(varargin)
            % Constructor method
            %
            % Supported arguments are:
            %
            %  'SiteName'
            %  'SiteID'
            %  'Easting'
            %  'Northing'
            %  'WaterDepth'
            %
            % Each of these can be set after instantiation if preferred.
            %
            
            for i = 1:2:length(varargin) % only bother with odd arguments, i.e. the labels
              switch varargin{i}
                case 'Easting' % Set easting if passed in explicitly
                  P.Easting = varargin{i+1};
                case 'Northing' % Set northing if passed in explicitly
                  P.Northing = varargin{i+1};
                case 'SiteName' % Set site name if passed in explicitly
                  P.SiteName = varargin{i+1};
                case 'SiteID' % Set site ID if passed in explicitly
                  P.SiteID = varargin{i+1};
                case 'WaterDepth' % Set site ID if passed in explicitly
                  P.WaterDepth = varargin{i+1};
              end
            end  
        end
        
        function P = addBin(P, ts)
            % Add the passed in RCM.TimeSeries object to the profile. These
            % 'bins' are assumed to be added from the bed upwards, with
            % each subsequent addition representing a shallower bin.
            %
            
            P.Bins{end+1,1} = ts;
        end
        
        function f = first(P)
            % Returns the first, bottomost bin object in the profile
            
            f = P.Bins{1};
        end
        
        function f = last(P)
            % Returns the last (shallowest) bin object in the profile
            
            f = P.Bins{end};
        end
        
        function s = size(P)
            % Returns the number of depth bins contained in the profile
            
            s = size(P.Bins, 1);
        end
        
        function [data] = getAll(P, attribute)
            % Returns a vector representing the values associated with the passed in 
            % attribute for all 3 time series records in the profile.
            %
            % Usage:
            %
            %   [table] = getAll(attribute)
            %
            % Example:
            %
            %   profile.getAll('MeanSpeed')
            %   ans =
            %      0.088321924144311        0.0864357076780758        0.0282062904717854
            %

            data = zeros(1,P.size);
            
            for i = 1:P.size
                data(1,i) = P.Bins{i}.(attribute);
            end
        end
        
        function P = setAll(P, attribute, val)
            % Sets the passed in attribute for all bins in
            % the profile to the passed in value
            %
            % Usage:
            %
            %   setAll(attribute, val)
            %
            % Example:
            %
            %   profile.setAll('Easting', 123456)
            %
            
            for i = 1:P.size
                P.Bins{i}.(attribute) = val;
            end
        end
        
        function bool = allEqual(P, attribute)
            % Returns true if the passed in attribute is consistent among
            % each of the bins in the profile
            
            % Get each of the values for the attribute from each bin
            vals = P.getAll(attribute);
            
            % Compare the first value with each subsequent value in turn
            % Store the comparison as a boolean.
            % Note, we have n-1 comparisons.
            bools = zeros(1,P.size - 1);            
            for i = 1:size(bools, 2)
                bools(1,i) = all(isequal(vals(:,1), vals(:,i+1)));
            end;
            
            % Establish is all comparisons are true or not.
            bool = all(bools);
        end
              
        function set.Easting(P, val)
            % Set the Easting property of the profile to the passed in
            % value and cascades this value down to each of the bins
            %
            % Example
            %
            %   profile.Easting = 123456
            %
            
            P.Easting = val;
            P.setAll('Easting', val)
        end
        
        function set.Northing(P, val)
            % Set the Northing property of the profile to the passed in
            % value and cascades this value down to each of the bins
            %
            % Example
            %
            %   profile.Northing = 987654
            %
            
            P.Northing = val;
            P.setAll('Northing', val)
        end
        
        function syncAttribute(P, attribute)
            % Attempts to synchronise an attribute of the profile with the
            % same attribute on the associated depth bins.
            %
            % If the attribute is not set on the profile, then it is
            % populate by the value fo the attribute from the associated
            % depth bins - if the bins values are consistent with one
            % another.
            %
            % If the attribute is set on the profile, it is cascaded to all
            % depth bins.
            
            %
            % This method only supports attributes which are common to the
            % profile and bin (TimeSeries) objects. In the default case,
            % these are:
            %
            %  'Easting'
            %  'Northing'
            %
            
            if isnan(P.(attribute)) 
                if P.allEqual(attribute)
                    P.(attribute) = P.first.(attribute);
                else
                    disp(['Cannot obtain ', attribute,...
                         ' from bin objects. The attribute is either missing or inconsistent.'])
                end
            else
                P.setAll(attribute, P.(attribute))
            end
        end
        
        function [lat, lng] = latLng(P)
            % Returns the latitude and longitude of the profile
            %
            % Usage
            %
            %   [lat, lng] = latLng()
            %
            
            [lng,lat] = P.first.latLng;
        end
        
        function [dn] = startTime(P)
            % Returns the start date of the dataset.
            
            dn = P.first.startTime;
        end
        
        function [sds] = startTimeString(P)
            % Returns the start date of the dataset formatted as a string.
            
            sds = datestr(P.startTime);
        end
        
        function [str] = toStruct(P)
            % Returns a struct representation of the object.
            
            str = struct(P);
            
            for i = 1:size(P.Bins, 1)
                str.Bins{i} = struct(P.Bins{i});
            end
        end
        
        function [str] = toArchiveStruct(P)
            % Returns a struct representation of the object with the names
            % of some fields changed to be consistent with OceanMet archive
            % conventions
            
            str = struct(P);
            
            for i = 1:size(P.Bins, 1)
                str.Bins{i} = P.Bins{i}.toArchiveStruct;
            end
        end
        
        function removeEmptyBins(P)
            % Removes any empty fields in the Bins vector.
            
            P.Bins(cellfun(@isempty,P.Bins)) = [];
        end
                   
        function speedAndDirectionTimeSeries(P, bins)
            % Generates a time series plot showing the magnitudes and
            % directions for each depth bin on the profile. Raw and 
            % harmonically reconstructed data is shown on all plots.
            
            binCount = size(bins, 2);
            
            figure;
            h = zeros(binCount*2,1);
            
            % Speed subplots
            for i = 1:binCount
                % Display in reverse order so that shallow bins are near
                % the top.
                
                h(i)=subplot(binCount*2,1,binCount+1-i);
                plot(P.Bins{bins(i)}.Time,P.Bins{bins(i)}.Speed,'r');
                hold on
                plot(P.Bins{bins(i)}.Time, P.Bins{bins(i)}.SpeedTidal,'b');
                grid on
            end
            
            % Direction subplots
            for i = 1:binCount
                h(i+binCount)=subplot(binCount*2,1,(2*binCount)+1-i);
                plot(P.Bins{bins(i)}.Time,P.Bins{bins(i)}.Direction,'b');
                hold on
                plot(P.Bins{bins(i)}.Time, P.Bins{bins(i)}.DirectionTidal,'r');
                grid on
            end
            
%             adjustAxes;
%             linkaxes(h,'x');
%             pan xon;      
        end
                
        function scatterPlot3D(P)
            % Generates a 3D scatterplot showing the current vectors for each depth
            % bin on the profile.
            %
            % Harmonically reconstructed current vectors are shown in red.
            %
            % Concentric circles on the base of the plot describe the
            % resuspension and deposition thresholds used in AutoDepomod.
            %
            
            colours = {'.magenta' '.green' '.blue'};
            
            figure;
            
            for b = [P.validBinIndexes]
                height(1,1:length(P.Bins{b}.u)) = P.Bins{b}.HeightAboveBed;
                plot3(P.Bins{b}.u, P.Bins{b}.v, height, colours{mod(b,3)+1});
                hold on
                plot3(P.Bins{b}.uTidal, P.Bins{b}.vTidal, height,'.red'); 
            end
                        
            r=0.095;
            ang=0:0.01:2*pi; 
            xp=r*cos(ang);
            yp=r*sin(ang);
            LengthAng=length(ang);
            zp(1:LengthAng)= 0;
            plot3(0+xp,0+yp,zp,'-black');

            r1=0.045;
            ang1=0:0.01:2*pi; 
            xp1=r1*cos(ang1);
            yp1=r1*sin(ang1);
            LengthAng1=length(ang1);
            zp1(1:LengthAng1)= 0;
            plot3(0+xp1,0+yp1,zp1,'-cyan');

            grid on
            
            title([P.SiteName,' - 3D Scatter plot'])
        end
        
        function P = calculateHarmonics(P)
            % Invokes the .calculateHarmonics() method on each of the 
            % timeseries records on the profile.
            
            for i = 1:size(P.Bins, 1)
                P.Bins{i}.calculateHarmonics;
            end
        end
        
        function [ind] = validBinIndexes(P)
            % Returns the indexes of the Bins vector that contain objects
            
            ind = find(~cellfun(@isempty, P.Bins))';
        end
    end
    
end

