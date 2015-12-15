function [ data ] = import(path, rowLimit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   import.m  $
% $Revision:   1.3  $
% $Author:   andrew.berkeley  $
% $Date:   Jan 21 2015 16:57:32  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a struct representing the DateTime, Speed, Direction and
    % Pressure columns from an HGAnalysis spreadsheet file.
    %
    % Usage:
    %
    %    [ data ] = RCM.HGAnalysis.import(path, rowLimit);
    %
    % where:
    %    path is the path to the .xls file.
    %
    %
    % OUTPUT:
    %    
    %   data: a struct with the following fields
    %
    %     Filename  : The full path of the file read
    %     Sheet     : The name of the tab read ('Current Meter Data')
    %     Easting   : The RCM location easting if available
    %     Northing  : The RCM location northing if available
    %     DataType  : Water or wind?
    %     DateTime  : Vector of datetimes as datenums
    %     Speed     : Vector of speeds 
    %     Direction : Vector of directions (degrees)
    %     Pressure  : Vector of pressure (water height)
    %
    %
    % EXAMPLES:
    %
    %  data = RCM.HGAnalysis.import('C:\...\...\Geasgill_surface_HGAnalysis_v7.xls')
    %  data = 
    %      Filename: 'C:\...\...\Geasgill bed HGdata_analysis_v7.xls'
    %         Sheet: 'Current Meter Data'
    %       Easting: 143657
    %      Northing: 737678
    %      DataType: []
    %      DateTime: [1081x1 double]
    %         Speed: [1081x1 double]
    %     Direction: [1081x1 double]
    %      Pressure: [1081x1 double]
    %
    % DEPENDENCIES:
    %
    %  - None
    % 
        
    if ~exist('rowLimit', 'var')
        rowLimit = '1089';
    end
    
    data = struct;
    data.Filename = path;
    data.Sheet    = 'Current Meter Data';
    data.Easting  = xlsread(data.Filename, data.Sheet, 'C1');
    data.Northing = xlsread(data.Filename, data.Sheet, 'D1');
    data.DataType = xlsread(data.Filename, data.Sheet, 'B5');
    
    data.DateTime  = [];
    data.Speed     = [];
    data.Direction = [];
    data.Pressure  = [];
    
    dataRowsColumns = ['A9:D', num2str(rowLimit)];
    
    % Import Current Meter Data
    %
    %  numData(:,1) = current speed (m/s)
    %  numData(:,2) = current direction (Deg-G)
    %  numData(:,1) = depth (pressure) (m)
    %
    %  textData(:,1) = date-time (GMT; dd/mm/yyyy hh:mm:ss)
    %
    [numData,textData,~] = xlsread(data.Filename, data.Sheet, dataRowsColumns);
    
    % Import Date & Time Surface
    for i=1:length(textData(:,1));
        if length(textData{i,1})==10;
            tempString=strcat(textData(i,1),' 00:00:00');
            data.DateTime(i)=datenum(tempString,'dd/mm/yyyy HH:MM:SS');
        else
            data.DateTime(i)=datenum(textData(i,1),'dd/mm/yyyy HH:MM:SS');
        end 
    end
    
    data.DateTime  = data.DateTime'; % transpose to make consistent
    data.Speed     = numData(:,1);
    data.Direction = numData(:,2);
    
    [~, columns] = size(numData);
    if columns > 2
        data.Pressure  = numData(:,3);
    end
end

