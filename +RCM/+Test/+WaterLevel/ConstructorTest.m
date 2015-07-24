classdef ConstructorTest < matlab.unittest.TestCase
    % 
    
    properties
        Time
        Pressure
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
            % Find the path to the RCM.Test directory
            testDir = what('RCM\+Test');
            
            % load the fixture data into the 'fixture' variable
            load([testDir.path,'\Fixtures\vestnessCurrents14m.mat']);
            
            % Memoize raw height data
            testCase.Time     = fixture.Time;
            testCase.Pressure = fixture.Pressure;
        end
    end
    
    methods (Test)
        
        function testBasicConstructor(testCase)
            wl = RCM.WaterLevel.TimeSeries;
            
            verifyEqual(testCase, class(wl), 'RCM.WaterLevel.TimeSeries');
            verifyEqual(testCase, wl.length, 0);
        end
        
        function testBasicConstructorAndPropertyAssignment(testCase)
            wl = RCM.WaterLevel.TimeSeries;
            wl.Time = testCase.Time;
            wl.Height = testCase.Pressure;
            
            verifyEqual(testCase, wl.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, wl.Height(1),    17.576);
            verifyEqual(testCase, wl.Height(100),  16.285);
            verifyEqual(testCase, wl.Height(1000), 16.669);
            
            verifyEqual(testCase, wl.length, 3368);
        end
        
        function testBasicConstructorSlackProperties(testCase)
            wl = RCM.WaterLevel.TimeSeries;
            wl.Time = testCase.Time;
            wl.Height = testCase.Pressure;
            
            verifyTrue(testCase, isempty(wl.isSlack));
            verifyTrue(testCase, isempty(wl.isHighWater));
            verifyTrue(testCase, isempty(wl.TidalRange));
        end
        
        function testBasicConstructorCalculateSlack(testCase)
            wl = RCM.WaterLevel.TimeSeries;
            wl.Time = testCase.Time;
            wl.Height = testCase.Pressure;
            
            wl.calculateSlackInfo;
            
            verifyFalse(testCase, isempty(wl.isSlack));     % set
            verifyFalse(testCase, isempty(wl.isHighWater)); % set
            verifyTrue(testCase,  isempty(wl.TidalRange));  % not yet set
            
            verifyEqual(testCase, length(wl.isSlack),     3368);
            verifyEqual(testCase, length(wl.isHighWater), 3368);
            verifyEqual(testCase, length(wl.TidalRange),     0);
        end
        
        function testBasicConstructorCalculateTidalRanges(testCase)
            wl = RCM.WaterLevel.TimeSeries;
            wl.Time = testCase.Time;
            wl.Height = testCase.Pressure;
            
            wl.calculateTidalRanges;
            
            verifyFalse(testCase, isempty(wl.isSlack));     % set
            verifyFalse(testCase, isempty(wl.isHighWater)); % set
            verifyFalse(testCase,  isempty(wl.TidalRange)); % set
            
            verifyEqual(testCase, length(wl.isSlack),     3368);
            verifyEqual(testCase, length(wl.isHighWater), 3368);
            verifyEqual(testCase, length(wl.TidalRange),  3368);
        end
        
        function testCreateConstructor(testCase)
            wl = RCM.WaterLevel.TimeSeries.create(testCase.Time, testCase.Pressure);
            
            verifyEqual(testCase, class(wl), 'RCM.WaterLevel.TimeSeries');
            verifyEqual(testCase, wl.length, 3368);
        end
        
        function testCreateConstructorDataAssignment(testCase)
            wl = RCM.WaterLevel.TimeSeries.create(testCase.Time, testCase.Pressure);
            
            verifyEqual(testCase, wl.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, wl.Height(1),    17.576);
            verifyEqual(testCase, wl.Height(100),  16.285);
            verifyEqual(testCase, wl.Height(1000), 16.669);
            
            verifyEqual(testCase, wl.length, 3368);
        end
        
        function testCreateConstructorSlackAndRangeProperties(testCase)
            wl = RCM.WaterLevel.TimeSeries.create(testCase.Time, testCase.Pressure);
            
            % These are automatically calculated in this constructor
            verifyFalse(testCase, isempty(wl.isSlack));     % set
            verifyFalse(testCase, isempty(wl.isHighWater)); % set
            verifyFalse(testCase,  isempty(wl.TidalRange)); % set
            
            verifyEqual(testCase, length(wl.isSlack),     3368);
            verifyEqual(testCase, length(wl.isHighWater), 3368);
            verifyEqual(testCase, length(wl.TidalRange),  3368);
        end
        
        function testTotalTideConstructor(testCase)
            % Mimic Total Tide struct
            totalTideStruct = struct('time', testCase.Time', 'height', testCase.Pressure);
            wl = RCM.WaterLevel.TimeSeries.fromTotalTideStruct(totalTideStruct);
            
            verifyEqual(testCase, class(wl), 'RCM.WaterLevel.TimeSeries');
            verifyEqual(testCase, wl.length, 3368);
        end
        
        function testTotalTideConstructorDataAssignment(testCase)
            % Mimic Total Tide struct
            totalTideStruct = struct('time', testCase.Time', 'height', testCase.Pressure);
            wl = RCM.WaterLevel.TimeSeries.fromTotalTideStruct(totalTideStruct);
            
            verifyEqual(testCase, wl.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, wl.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, wl.Height(1),    17.576);
            verifyEqual(testCase, wl.Height(100),  16.285);
            verifyEqual(testCase, wl.Height(1000), 16.669);
            
            verifyEqual(testCase, wl.length, 3368);
        end
        
        function testTotalTideConstructorSlackAndRangeProperties(testCase)
            % Mimic Total Tide struct
            totalTideStruct = struct('time', testCase.Time', 'height', testCase.Pressure);
            wl = RCM.WaterLevel.TimeSeries.fromTotalTideStruct(totalTideStruct);
            
            % These are automatically calculated in this constructor
            verifyFalse(testCase, isempty(wl.isSlack));
            verifyFalse(testCase, isempty(wl.isHighWater)); 
            verifyFalse(testCase, isempty(wl.TidalRange));
            
            verifyEqual(testCase, length(wl.isSlack),     3368);
            verifyEqual(testCase, length(wl.isHighWater), 3368);
            verifyEqual(testCase, length(wl.TidalRange),  3368);
        end

    end
end