classdef GeneralTest < matlab.unittest.TestCase
    % 
    
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
            % pressure)
            testCase.TimeSeries = RCM.WaterLevel.TimeSeries.create(fixture.Time, fixture.Pressure);
        end
    end
    
    methods (Test)
        
        function testClass(testCase)
            verifyEqual(testCase, class(testCase.TimeSeries), 'RCM.WaterLevel.TimeSeries');
        end
        
        function testIsSlack(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(2), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(4), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(6), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(8), 1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(10), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(12), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(14), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(16), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(18), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(20), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(22), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(24), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(27), 1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(28), 0)
        end
        
        function testIsSlackForSlackOnlyObject(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(2), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(4), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(6), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(8), 1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(10), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(12), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(14), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(16), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(18), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(20), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(22), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(24), 0)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(27), 1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(28), 0)
        end
        
        function testIsHighWater(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(2), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(4), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(6), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(8), 1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(10), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(12), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(14), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(16), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(18), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(20), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(22), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(24), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(27), 0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(28), 0)
        end
        
        function testTidalRange(testCase)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(2), NaN)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(4), NaN)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(6), NaN)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(8),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(10), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(12), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(14), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(16), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(18), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(20), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(22), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(24), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(27),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(28),  1.731, 'AbsTol', 0.0001)
        end
        
        function testTidalRangeFollowingTruncate(testCase)
            testCase.TimeSeries.truncateByIndex('startIndex', 10);
            
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(2),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(4),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(6),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(8),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(10), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(12), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(14), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(16), -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(18),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(20),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(22),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(24),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(27),  1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(28),  1.731, 'AbsTol', 0.0001)
        end
        
        function testMean(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.mean,  17.32936, 'AbsTol', 0.0001)
        end
        
        function testMax(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.max,  19.05399, 'AbsTol', 0.0001)
        end
        
        function testMin(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.min,  15.23499, 'AbsTol', 0.0001)
        end
        
        function testRanges(testCase)
            % Start and end cannot be computed - NaNs
            
            ranges = testCase.TimeSeries.ranges;
            
            verifyEqual(testCase, ranges(1),     NaN, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(2),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(3),   1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(end),   NaN, 'AbsTol', 0.0001)
        end
        
        function testRangesFollowingTruncate(testCase)
            % Start and end are found in memoised TidalRange vector
            
            testCase.TimeSeries.truncateByIndex('startIndex', 10);
            ranges = testCase.TimeSeries.ranges;
            
            verifyEqual(testCase, ranges(1),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(2),   1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(3),  -2.111, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(end),   NaN, 'AbsTol', 0.0001)            
        end
        
        function testMeanRange(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.meanRange,  2.36354, 'AbsTol', 0.0001)
        end
        
        function testMaxRange(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.maxRange,  3.81899, 'AbsTol', 0.0001)
        end
        
        function testMinRange(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.minRange,  0.85500, 'AbsTol', 0.0001)
        end
        
        function testSlackIndexes(testCase)
            indexes = testCase.TimeSeries.slackIndexes;
            
            verifyEqual(testCase, indexes(1),   8);
            verifyEqual(testCase, indexes(2),  27);
            verifyEqual(testCase, indexes(3),  45);
            verifyEqual(testCase, indexes(4),  64);
            verifyEqual(testCase, indexes(5),  83);
            verifyEqual(testCase, indexes(6), 100);
        end
        
        function testHighWaterIndexes(testCase)
            indexes = testCase.TimeSeries.highWaterIndexes;
            
            verifyEqual(testCase, indexes(1),   8);
            verifyEqual(testCase, indexes(2),  45);
            verifyEqual(testCase, indexes(3),  83);
            verifyEqual(testCase, indexes(4),  120);
        end
        
        function testLowWaterIndexes(testCase)
            indexes = testCase.TimeSeries.lowWaterIndexes;
            
            verifyEqual(testCase, indexes(1),  27);
            verifyEqual(testCase, indexes(2),  64);
            verifyEqual(testCase, indexes(3), 100);
            verifyEqual(testCase, indexes(4), 137);
        end
        
        function testIsSlackOnly(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isSlackOnly, 0);
        end
        
        
    end
end
