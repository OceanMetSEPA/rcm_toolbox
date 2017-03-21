%% Load in example data

testDir = what('RCM\+Test');
load([testDir.path,'\Fixtures\currents1.mat']);       
rawData = fixture
clear fixture

% Returns a struct of current data
%
% rawData = 
%               Time: [3368x1 double]
%              Speed: [3368x1 double]
%          Direction: [3368x1 double]
%           Pressure: [3368x1 double]
%            Easting: 347967
%           Northing: 1049310
%     HeightAboveBed: 14

%% Create water level object from raw data

% a water level object simply requires a time vector and a water level
% vector
wl = RCM.WaterLevel.TimeSeries.create(rawData.Time, rawData.Pressure)

% wl = 
%   TimeSeries with properties:
% 
%            Height: [3368x1 double]
%           isSlack: [3368x1 double]
%       isHighWater: [3368x1 double]
%        TidalRange: [3368x1 double]
%              Time: [3368x1 double]
%           Easting: NaN
%          Northing: NaN
%          Latitude: NaN
%         Longitude: NaN
%     TotalTidePort: []

%% Get some sumamry statistics

% mean water level described by the dataset
wl.mean

% maximum water level
wl.max

% minimum water level
wl.min

% mean tidal range described by dataset
wl.meanRange

% maximum tidal range
wl.maxRange

% minimum tidal range
wl.minRange


%% Operate with slack water data points only

% get a vector of indexes identifying each slack water data point
wl.slackIndexes

% get just the high water indexes
wl.highWaterIndexes

% or low water indexes
wl.lowWaterIndexes

% get a vector of all the times corresponding to slack events
wl.slackTime

% and the corresponding heights
wl.slackHeight

% Or, if the above are too faffy, just create a new water level object comprising 
% only the slack datapoints
slackWL = wl.toSlackOnly

% slackWL = 
%   TimeSeries with properties:
% 
%            Height: [181x1 double]
%           isSlack: [181x1 double]
%       isHighWater: [181x1 double]
%        TidalRange: [181x1 double]
%              Time: [181x1 double]
%           Easting: NaN
%          Northing: NaN
%          Latitude: NaN
%         Longitude: NaN
%     TotalTidePort: []

% Notice the reduced number of datapoints.

slackWL.plot

%% Obtain spring-neap contextal information for every datapoint

% return a vector of 1s (spring) and -1s (neap) describing whether each
% point occurs during the spring or neap phase
wl.isSpringOrNeap

% return a vector of continously varying values between 1 (spring max) 
% and -1 (neap max) describing the position of each data point in the
% spring-neap cycle
wl.springNeapPhase

% return a boolean vector identifying the spring-neap inflection points
wl.isSpringNeapInflection

% return a boolean vector identifying the spring extreme water levels
wl.isSpringMax


%% Plot water level

wl.plot

%% plot with slack points highlighted

wl.plotWithSlackPoints

%% Normalize the water levels to mean sea level

wl.normalise
wl.plot

% This changes the object in situ. If the original object needs to be
% retained a new normailised water level object can be instantiated like
% this:

normWL = wl.toNormalised

