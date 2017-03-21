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

%% Create a current time series object

% a current object simply requires a time vector, a speed vector and a
% direction vector
ts = RCM.Current.TimeSeries.create(rawData.Time, rawData.Speed, rawData.Direction)

% Returns time series object with various derived statistics
%
% ts = 
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
%                         Easting: NaN
%                        Northing: NaN
%                        Latitude: NaN
%                       Longitude: NaN
%                       

% Note, current time series objects can alternatively be instantiated using
% u and v components from which speed and direction are calculated
% automatically:
%
% ts = RCM.Current.TimeSeries.createFromComponents(time, u, v)
%
% A further way to instantiate is to pass in the path of a SEPA HGAnalysis
% xls file
%
% ts = RCM.Current.TimeSeries.fromHGAnalysisXls(path)
%

%% Inspect time series

ts.MeanSpeed
ts.MajorAxis
ts.ResidualSpeed

%% Add additional data

% Notice the object has no location information or pressure record. We can
% add those either to the existing object:

ts.Pressure = rawData.Pressure
ts.Easting  = rawData.Easting
ts.Northing = rawData.Northing
ts.HeightAboveBed = rawData.HeightAboveBed

% or at the outset:

ts = RCM.Current.TimeSeries.create(rawData.Time, rawData.Speed, rawData.Direction, ...
    'Pressure', rawData.Pressure, 'Easting', rawData.Easting, 'Northing', rawData.Northing)

% Notice the lat/long are automatically calculated from the
% easting/northings, though this requires the [os_toolbox](https://github.com/OceanMetSEPA/os_toolbox) 
% being available on the local MATLAB path 
%
% ts = 
%   TimeSeries with properties:
% 
%                           Speed: [3368x1 double]
%                       Direction: [3368x1 double]
%                        Pressure: [3368x1 double]
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
                      
%% Produce a scatter plot

ts.scatterPlot

%% Produce a time series plot (requires pressure)

ts.timeSeriesPlot

%% Produce a cumulative vector plot

ts.cumulativeVectorPlot

%% Calculate tidal harmonics

% This requires a value in the .Latitude property as well as the [UTide
% library](https://uk.mathworks.com/matlabcentral/fileexchange/46523--utide--unified-tidal-analysis-and-prediction-functions)
% being available on the local MATLAB path

ts.calculateHarmonics

%   TimeSeries with properties:
% 
%                           Speed: [3368x1 double]
%                       Direction: [3368x1 double]
%                        Pressure: [3368x1 double]
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
%                TideCoefficients: [1x1 struct]
%                          uTidal: [3368x1 double]
%                          vTidal: [3368x1 double]
%                       uNonTidal: [3368x1 double]
%                       vNonTidal: [3368x1 double]
%                      SpeedTidal: [3368x1 double]
%                  DirectionTidal: [3368x1 double]
%                   SpeedNonTidal: [3368x1 double]
%               DirectionNonTidal: [3368x1 double]
%                       Tideyness: 0.883147980547711
%                   TotalTidePort: []
%                            Time: [3368x1 double]
%                         Easting: 347967
%                        Northing: 1049310
%                        Latitude: 59.3269435794742
%                       Longitude: -2.91611130236019

% Notice now that the tidal and non-tidal speed, direction, u and v vectors are now populated.
% The harmonomic constituent information is available in the
% .TideCoefficients property.

%% Water levels

% If a pressure record is available then this can be analysed as a
% RCM.WaterLevel.TimeSeries object

ts.waterLevels

%   TimeSeries with properties:
% 
%            Height: [3368x1 double]
%           isSlack: [3368x1 double]
%       isHighWater: [3368x1 double]
%        TidalRange: [3368x1 double]
%              Time: [3368x1 double]
%           Easting: 347967
%          Northing: 1049310
%          Latitude: 59.3269435794742
%         Longitude: -2.91611130236019
%     TotalTidePort: []

ts.waterLevels.plot


