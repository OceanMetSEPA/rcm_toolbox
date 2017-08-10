% All time series objects, that is RCM.Current.TimeSeries and
% RCM.WaterLevel.TimeSeries, have a large range of general functions that
% enable them to be manipulated in various ways: cloning, truncating,
% repeating, etc.

%% Prepare an example time series

% load some raw data
testDir = what('RCM\+Test');
load([testDir.path,'\Fixtures\currents1.mat']);       
rawData = fixture
clear fixture

% Initialise Current TimeSeries object
ts = RCM.Current.TimeSeries.create(rawData.Time, rawData.Speed, rawData.Direction, 'Easting', rawData.Easting, 'Northing', rawData.Northing)

% Initialise WaterLevel TimeSeries object
wl = RCM.WaterLevel.TimeSeries.create(rawData.Time, rawData.Pressure)

%% Get information about the scope of any timeseries

% get the number of records in the time series
ts.length

% get the start time as a MATLAB datenum
ts.startTime

% get the end time as a MATLAB datenum
ts.endTime

% get the length of the time series in days
ts.lengthDays

% get the time resolution in seconds
ts.timeIntervalSeconds

% get the time resolution in days
ts.timeIntervalDays

% get the number of spring-neap cycles in the time series
ts.springNeapCycleCount

% get the index of the record which is closest to the passed in time
ts.closestRecordToTimeIndex(735677)

% ans =
%    455

%% Create a clone of the time series

ts2 = ts.clone

% ts2 = 
%   TimeSeries with properties:
% 
%                           Speed: [3368x1 double]
%                       Direction: [3368x1 double]
%                        Pressure: []
%                  HeightAboveBed: NaN
%                               u: [3368x1 double]
%                               v: [3368x1 double]
%               ParallelComponent: [3368x1 double]
%                 NormalComponent: [3368x1 double]
%                       MeanSpeed: 0.148551543942993
%                       MajorAxis: 328.824715628245
%               ParallelAmplitude: 0.199794139081701
%                 NormalAmplitude: 0.0798758943244569
%             AmplitudeAnisotropy: 2.50130706856482
%                   ResidualSpeed: 0.0710841926310581
%               ResidualDirection: 4.06993845731955
%     ResidualConsistentMajorAxis: 328.824715628245
%          ResidualMajorAxisAngle: 35.2452228290748
%                TideCoefficients: []
%                          uTidal: []
%                          vTidal: []
%                       uNonTidal: []
%                       vNonTidal: []
%                      SpeedTidal: []
%                  DirectionTidal: []
%                   SpeedNonTidal: []
%               DirectionNonTidal: []
%                       Tideyness: NaN
%                   TotalTidePort: []
%                            Time: [3368x1 double]
%                         Easting: 347967
%                        Northing: 1049310
%                        Latitude: 59.3269435794742
%                       Longitude: -2.91611130236019

% This new object is identical to the original. This function is useful
% when used in the context of some of the following functions if the
% original time series is required unchanged.

%% Truncating the time series by index

% Any time series object can be truncated in a variety of ways. For example
% by selecting the indexes at which to remove datapoints.

% Let's start by establishing the initial length of the record
ts2.length

% ans =
%         3368

% Remove 68 data points from the end
ts2.truncateByIndex('endIndex', 3300)

% And the new length is...
ts2.length

% ans =
%         3300

% Now remove 10 records from the start AND end
ts2.truncateByIndex('startIndex', 11, 'endIndex', 3290)

% New length ...
ts2.length
% ans =
%         3280

%% Truncating the time series by time

% Time series can be similarly truncated according to the time. This
% involves the .truncateByTime() method and either the 'startTime' or
% 'endTime' options or both.

ts2.startTime

% ans =
%           735670.837719907

% Okay, now lets truncate about 5 days from the start. Let's supply a new
% start time.
ts2.truncateByTime('startTime', 735675)

% Verify the new start time
ts2.startTime

% ans =
%           735675.004386574

% This represents the closest record in the original dataset to the
% required time. And the size of the dataset now...

ts2.length

% ans =
%         2980

% Shorter than before. Passing in an 'endTime' works in the same way.

%% Truncating the time series by number of days

% A time series can be truncated to a particular number of days

ts2.lengthDays
 
% ans =
%         41.375

ts2.truncateToDays(20)

% And the new length
ts2.lengthDays

% ans =
%         20

%% Truncating the time series to a single spring-neap cycle

ts2.truncateToSpringNeapCycle

ts2.lengthDays

% ans =
%         14.763888888876

%% Repeating the time series a number of times

% Time series can be extendeding by repeating with a number identical cycles. The number
% passed in represent the number of cycles desired in the resulting time series

ts2.repeat(2)

ts2.lengthDays

% ans =
%         29.5416666666279

%% Repeating a time series for a specified number of days

% This function is shorthand for .repeat() and .truncateToDays()

ts2.repeatForDays(60)

ts2.lengthDays

% ans =
%           59.9999999998836

% The resultant number of days may not be exactly as requested due to the
% resolution of the data

%% Repeating a spring-neap cycle

% This function enables just the first spring-neap cycle to be repeated,
% for a specified number of days

ts2.repeatSpringNeapCycle(50)

ts2.lengthDays

% ans =
%           50