classdef WaterLevelTest < matlab.unittest.TestCase
    
    properties
        TimeSeries
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
            % Find the path to the RCM.Test directory
            testDir = what('RCM\+Test');
            
            % load the fixture data into the 'fixture' variable
            load([testDir.path,'\Fixtures\currents1.mat']);
            
            % Instantiate a TimeSeries object using fixture data (time,
            % speed, direction, pressure)
            testCase.TimeSeries = RCM.Current.TimeSeries();
            
            testCase.TimeSeries.Time      = fixture.Time;
            testCase.TimeSeries.Speed     = fixture.Speed;
            testCase.TimeSeries.Direction = fixture.Direction;
            testCase.TimeSeries.Pressure  = fixture.Pressure;
            testCase.TimeSeries.Easting   = fixture.Easting;
            testCase.TimeSeries.Northing  = fixture.Northing;
        end
    end
    
    methods (Test)
        
    end
end
