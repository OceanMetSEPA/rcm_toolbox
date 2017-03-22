%% Create a water level object directly from Admiralty TotalTide

% This requires a working installation of TotalTide and also either
% easting/northing or lat/long references

% pass in the start date as a datenum and the length required in days
wl = RCM.WaterLevel.TimeSeries.fromTotalTide(now, 30, 'easting', 164789, 'northing', 709911)

% wl = 
%   TimeSeries with properties:
% 
%            Height: [720x1 double]
%           isSlack: [720x1 double]
%       isHighWater: [720x1 double]
%        TidalRange: [720x1 double]
%              Time: [720x1 double]
%           Easting: 164789
%          Northing: 709911
%          Latitude: 56.116666
%         Longitude: -5.783333
%     TotalTidePort: [1x1 Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort]

% This dataseries can no be manipulated according the functionality on the
% RCM.WaterLevel.TimeSeries class

wl.normalise
wl.meanRange

% etc...
    
%% Get the closest TotalTide port to any time series

% Any RCM TimeSeries object, whether Current or WaterLevel, can be used as the basis 
% for discovering the nearest TotalTide port

% load some raw data
testDir = what('RCM\+Test');
load([testDir.path,'\Fixtures\currents1.mat']);       
rawData = fixture
clear fixture

% Initialise Current TimeSeries object
ts = RCM.Current.TimeSeries.create(rawData.Time, rawData.Speed, rawData.Direction, 'Easting', rawData.Easting, 'Northing', rawData.Northing)

% Obtain nearest Total Tide port (requires geographic information on the time series)
port = ts.getTotalTidePort

% port =
% 	Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort
%                      Number: '0277'
%                        Name: 'Pierowall'
%                    Latitude: 59.316666
%                   Longitude: -2.983333
%                 StationType: 'PortNonHarmonic'
%                      IsPort: 1
%                    IsStream: 0
%                    Filtered: 1
%                     Country: 'Scotland'
%                    ZoneTime: 0
%                      Height: 1.9118896994554
%            HighestHighWater: 3.7
%             LowestHighWater: 2.8
%             HighestLowWater: 1.4
%              LowestLowWater: 0.6
%                MeanSeaLevel: [1x105 char]
%      DaysToOrFromSpringTide: -6
%     HighestAstronomicalTide: 4.3
%      LowestAstronomicalTide: -0.1
%         MinimumDisplayScale: 5000000
%                  TypeOfPort: 'PortSecondaryNonHarmonic'

% This can be used to form the basis of subsequent TotalTide queries. It is
% memoised on the time series object for easy access in the TotalTidePort property.

%% Get a TotalTide water level record for the nearest port to any time series

% Any RCM TimeSeries object, whether Current or WaterLevel, can generate a
% corresponding TotalTide water level time series easily. If the nearest
% port is not yet know then it is established automatically and is memoised
% on the time object for subsequent queries.

% Obtain Total Tide water level from nearest port (requires geographic information on the time series)
wl = ts.totalTideWaterLevels

% wl = 
%   TimeSeries with properties:
% 
%            Height: [1123x1 double]
%           isSlack: [1123x1 double]
%       isHighWater: [1123x1 double]
%        TidalRange: [1123x1 double]
%              Time: [1123x1 double]
%           Easting: 347967
%          Northing: 1049310
%          Latitude: 59.316666
%         Longitude: -2.983333
%     TotalTidePort: [1x1 Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort]

% By default this function generates a water level record corresponding to
% exactly the time period of the time series at 60 minute resolution. These
% can be altered by specifying the lengthDays, offsetDays (relative to the time 
% series start date), and resolution (in minutes) options.

%% Get a year of TotalTide water levels around the time series start date

% To quickly get a years worth of water level data from TotalTide in
% reference to the location and start time of a TimeSeries object then:

wl = ts.totalTideYear

% wl = 
%   TimeSeries with properties:
% 
%            Height: [8760x1 double]
%           isSlack: [8760x1 double]
%       isHighWater: [8760x1 double]
%        TidalRange: [8760x1 double]
%              Time: [8760x1 double]
%           Easting: 347967
%          Northing: 1049310
%          Latitude: 59.316666
%         Longitude: -2.983333
%     TotalTidePort: [1x1 Interface.CherSoft_TotalTide_Application_1.0_Type_Library.IPort]

% This may take a few seconds due to the nature of the TotalTide API.