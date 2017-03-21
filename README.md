# rcm_toolbox
MATLAB toolbox for processing and interpreting recording current meter data.

This library prvides a range of functionality for handling and analysing current meter data, including current (i.e. flow) and water level (pressure) timeseries. This functionality includes summary statistics, harmonic analysis (using UTide) and some plotting. More advanced functionality enables timeseries to be truncated, repeated, cloned and concatenated.

## Dependencies
This toolbox works best with the following packages
- the [os_toolbox](https://github.com/OceanMetSEPA/os_toolbox) MATLAB library
- the [UTide](https://uk.mathworks.com/matlabcentral/fileexchange/46523--utide--unified-tidal-analysis-and-prediction-functions) MATLAB library
- A working and authorised copy of Admiralty TotalTide software
- the [totaltide_toolbox](https://github.com/OceanMetSEPA/totaltide_toolbox) MATLAB library

## Examples

The following examples are reproduced with sample data in the \scripts directory.

### Current data

#### Create a current time series object

A current object simply requires a time vector, a speed vector and a direction vector

    ts = RCM.Current.TimeSeries.create(timeVector, speedVector, directionVector)

Which returns a time series object with various derived statistics

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

Note, current time series objects can alternatively be instantiated using u and v components from which speed and direction are calculated automatically:

    ts = RCM.Current.TimeSeries.createFromComponents(timeVector, uVector, vVector)

And a final way is to pass in the path of a SEPA HGAnalysis xls file

    ts = RCM.Current.TimeSeries.fromHGAnalysisXls('\\path\to\file')

#### Inspect current time series

Values can be retrieved from current time series objects easily, e.g....

    ts.MeanSpeed
    ts.MajorAxis
    ts.ResidualSpeed

#### Add additional data
Notice the object has no location information or pressure record. These can be necessary for more complex analyses like tidal harmonic analysis (latitude) or otherwise understanding the flow in relation to water levels. We can add those either to the existing object:

    ts.Pressure = pressureVector
    ts.Easting  = easting
    ts.Northing = northing

or at the outset when we create the object:

    ts = RCM.Current.TimeSeries.create(timeVector, speedVector, directionVector, ...
        'Pressure', pressureVector, 'Easting', easting, 'Northing', northing)

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
        
Notice the lat/long are automatically calculated from the easting/northings, though this requires the [os_toolbox](https://github.com/OceanMetSEPA/os_toolbox) being available on the local MATLAB path 
              
#### Produce a scatter plot

    ts.scatterPlot

#### Produce a time series plot (requires pressure)

    ts.timeSeriesPlot

#### Produce a cumulative vector plot

    ts.cumulativeVectorPlot

#### Calculate tidal harmonics

This requires a value in the .Latitude property as well as the [UTide MATLAB library](https://uk.mathworks.com/matlabcentral/fileexchange/46523--utide--unified-tidal-analysis-and-prediction-functions) being available on the local MATLAB path

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

Notice now that the tidal and non-tidal speed, direction, u and v vectors are now populated. The harmonomic constituent information is available in the .TideCoefficients property.

#### Water levels associated with current data  

If a pressure record is available then this can be analysed as a RCM.WaterLevel.TimeSeries object

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

More on these objects, next.

### Water level data


#### Create water level object from raw data

A water level object simply requires a time vector and a water level vector

    wl = RCM.WaterLevel.TimeSeries.create(timeVector, pressureVector)

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

#### Get some summary statistics

Mean water level described by the dataset
    
    wl.mean

Maximum water level

    wl.max

Minimum water level

    wl.min

Mean tidal range described by dataset
    
    wl.meanRange

Maximum tidal range

    wl.maxRange

Minimum tidal range

    wl.minRange


#### Operate with slack water data points only

Get a vector of indexes identifying each slack water data point

    wl.slackIndexes

Get just the high water indexes

    wl.highWaterIndexes

Or low water indexes

    wl.lowWaterIndexes

Get a vector of all the times corresponding to slack events
    
    wl.slackTime

And the corresponding heights

    wl.slackHeight

Or, if the above are too faffy, just create a new water level object comprising only the slack datapoints
    
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

Notice the reduced number of datapoints.

#### Obtain spring-neap contextal information for every datapoint

Return a vector of 1s (spring) and -1s (neap) describing whether each point occurs during the spring or neap phase

    wl.isSpringOrNeap

Return a vector of continously varying values between 1 (spring max) and -1 (neap max) describing the position of each data point in the spring-neap cycle

    wl.springNeapPhase

Return a boolean vector identifying the spring-neap inflection points

    wl.isSpringNeapInflection

Return a boolean vector identifying the spring extreme water levels

    wl.isSpringMax


#### Plot water level

    wl.plot

and with slack points highlighted

    wl.plotWithSlackPoints

#### Normalize the water levels to mean sea level

    wl.normalise
    wl.plot

This changes the object in situ, basically subtracting the mean water depth from all values and resulting in a time series with a mean of ~0.

If the original object needs to be retained a new normailised water level object can be instantiated like this:

    normWL = wl.toNormalised

### Interacting with Admiralty TotalTide

If a working installation of TotalTide is available then data can be retrieved directly into RCM.WaterLevel.TimeSeries object where it can be readily manipulated using the functionality described above.

#### Create a water level object directly from Admiralty TotalTide

This requires a working installation of TotalTide and also either easting/northing or lat/long references

Pass in the required start date as a datenum and the length required in days
    
    wl = RCM.WaterLevel.TimeSeries.fromTotalTide(now, 30, 'easting', 164789, 'northing', 709911)

which returns

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

This dataseries can no be manipulated according the functionality on the RCM.WaterLevel.TimeSeries class, e.g.:

    wl.normalise
    wl.meanRange

etc...
    
#### Get the closest TotalTide port to any time series

Any RCM TimeSeries object, whether Current or WaterLevel, can be used as the basis for discovering the nearest TotalTide port

Initialise Current TimeSeries object

    ts = RCM.Current.TimeSeries.create(timeVector, speedVector, directionVector, 'Easting', easting, 'Northing', northing)

Obtain nearest Total Tide port (requires geographic information on the time series)

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

This can be used to form the basis of subsequent TotalTide queries. It is memoised on the time series object for easy access in the TotalTidePort property.

#### Get a TotalTide water level record for the nearest port to any time series

Any RCM TimeSeries object, whether Current or WaterLevel, can generate a corresponding TotalTide water level time series easily. If the nearest port is not yet know then it is established automatically and is memoised on the time object for subsequent queries.

Obtain Total Tide water level from nearest port (requires geographic information on the time series)

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

By default this function generates a water level record corresponding to exactly the time period of the time series at 60 minute resolution. These can be altered by specifying the lengthDays, offsetDays (relative to the time  series start date), and resolution (in minutes) options.

#### Get a year of TotalTide water levels around the time series start date

To quickly get a years worth of water level data from TotalTide in reference to the location and start time of a TimeSeries object then:

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

This may take a few seconds due to the nature of the TotalTide API.

### General timeseries functionality

All time series objects, that is RCM.Current.TimeSeries and RCM.WaterLevel.TimeSeries, have a large range of general functions that enable them to be manipulated in various ways: cloning, truncating, repeating, etc.

#### Get information about the scope of any timeseries

Get the number of records in the time series

    ts.length

Get the start time as a MATLAB datenum

    ts.startTime

Get the end time as a MATLAB datenum

    ts.endTime

Get the length of the time series in days

    ts.lengthDays

Get the time resolution in seconds

    ts.timeIntervalSeconds

Get the time resolution in days

    ts.timeIntervalDays

Get the number of spring-neap cycles in the time series

    ts.springNeapCycleCount

Get the index of the record which is closest to the passed in time

    ts.closestRecordToTimeIndex(735677)

    % ans =
    %    455

#### Create a clone of the time series

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

This new object is identical to the original. This function is useful when used in the context of some of the following functions if the original time series is required unchanged.

#### Truncating the time series by index

Any time series object can be truncated in a variety of ways. For example by selecting the indexes at which to remove datapoints.

Let's start by establishing the initial length of the record

    ts2.length

    % ans =
    %         3368

Now, remove 68 data points from the end

    ts2.truncateByIndex('endIndex', 3300)

And the new length is...

    ts2.length

    % ans =
    %         3300

Now remove 10 records from the start AND end

    ts2.truncateByIndex('startIndex', 11, 'endIndex', 3290)

New length ...

    ts2.length

    % ans =
    %         3280

#### Truncating the time series by time

Time series can be similarly truncated according to the time. This involves the .truncateByTime() method and either the 'startTime' or 'endTime' options or both.

    ts2.startTime

    % ans =
    %           735670.837719907

Okay, now lets truncate about 5 days from the start. Let's supply a new start time.

    ts2.truncateByTime('startTime', 735675)

Verify the new start time

    ts2.startTime

    % ans =
    %           735675.004386574

This represents the closest record in the original dataset to the required time. And the size of the dataset now...

    ts2.length

    % ans =
    %         2980

Shorter than before. Passing in an 'endTime' works in the same way.

#### Truncating the time series by number of days

A time series can be truncated to a particular number of days. First, let's check the number of days currently,

    ts2.lengthDays
 
    % ans =
    %         41.375

Now truncate to 20 days.

    ts2.truncateToDays(20)

And the new length

    ts2.lengthDays

    % ans =
    %         20

#### Truncating the time series to a single spring-neap cycle

    ts2.truncateToSpringNeapCycle

Results in a record

    ts2.lengthDays

    % ans =
    %         14.763888888876

days long, as expected.

#### Repeating the time series a number of times

Time series can be extended by repeating with a number identical cycles. The number passed in represent the number of cycles desired in the resulting time series

    ts2.repeat(2)

    ts2.lengthDays

    % ans =
    %         29.5416666666279

#### Repeating a time series for a specified number of days

This function is shorthand for .repeat() and .truncateToDays()

    ts2.repeatForDays(60)

    ts2.lengthDays

    % ans =
    %           59.9999999998836

%he resultant number of days may not be exactly as requested due to the resolution of the data

#### Repeating a spring-neap cycle

This function enables just the first spring-neap cycle to be repeated, for a specified number of days

    ts2.repeatSpringNeapCycle(50)

    ts2.lengthDays

    % ans =
    %           50

