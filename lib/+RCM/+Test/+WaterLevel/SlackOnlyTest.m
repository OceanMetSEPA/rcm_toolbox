classdef SlackOnlyTest < matlab.unittest.TestCase
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
            
            % Instantiate a Slack Only TimeSeries object using fixture 
            % data (time, pressure)
            testCase.TimeSeries = RCM.WaterLevel.TimeSeries.create(fixture.Time, fixture.Pressure).toSlackOnly;
        end
    end
    
    methods (Test)
        
        function testClass(testCase)
            verifyEqual(testCase, class(testCase.TimeSeries), 'RCM.WaterLevel.TimeSeries');
        end
        
        function testIsSlack(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(1),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(2),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(3),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(4),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(5),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(6),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(7),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(8),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(9),   1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(10),  1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(11),  1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(12),  1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(13),  1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(14),  1)
            verifyEqual(testCase, testCase.TimeSeries.isSlack(end), 1)
        end
        
        function testIsHighWater(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(1),   1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(2),   0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(3),   1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(4),   0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(5),   1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(6),   0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(7),   1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(8),   0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(9),   1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(10),  0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(11),  1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(12),  0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(13),  1)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(14),  0)
            verifyEqual(testCase, testCase.TimeSeries.isHighWater(end), 1)
        end
        
        function testTidalRange(testCase)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(1),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(2),   1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(3),  -2.111, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(4),   1.862, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(5),  -1.851, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(6),   2.105, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(7),  -2.009, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(8),   2.118, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(9),  -2.309, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(10),  2.316, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(11), -2.639, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(12),  2.672, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(13), -2.456, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(14),  2.552, 'AbsTol', 0.0001)
        end
        
        function testTidalRangeFollowingTruncate(testCase)
            testCase.TimeSeries.truncateByIndex('startIndex', 10);
            
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(1),  2.316, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(2), -2.639, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(3),  2.672, 'AbsTol', 0.0001)
            verifyEqual(testCase, testCase.TimeSeries.TidalRange(4), -2.456, 'AbsTol', 0.0001)
        end
        
        function testMean(testCase)            
            verifyEqual(testCase, testCase.TimeSeries.mean,  17.28908, 'AbsTol', 0.0001)
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
            
            verifyEqual(testCase, ranges(1),  -1.457, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(2),   1.731, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(3),  -2.111, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(end), 2.954, 'AbsTol', 0.0001)
        end
        
        function testRangesFollowingTruncate(testCase)
            % Start and end are found in memoised TidalRange vector
            
            testCase.TimeSeries.truncateByIndex('startIndex', 10);
            ranges = testCase.TimeSeries.ranges;
            
            verifyEqual(testCase, ranges(1),   2.316, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(2),  -2.639, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(3),   2.672, 'AbsTol', 0.0001)
            verifyEqual(testCase, ranges(end), 2.954, 'AbsTol', 0.0001)            
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
            
            verifyEqual(testCase, indexes(1), 1);
            verifyEqual(testCase, indexes(2), 2);
            verifyEqual(testCase, indexes(3), 3);
            verifyEqual(testCase, indexes(4), 4);
            verifyEqual(testCase, indexes(5), 5);
            verifyEqual(testCase, indexes(6), 6);
        end
        
        function testHighWaterIndexes(testCase)
            indexes = testCase.TimeSeries.highWaterIndexes;
            
            verifyEqual(testCase, indexes(1),  1);
            verifyEqual(testCase, indexes(2),  3);
            verifyEqual(testCase, indexes(3),  5);
            verifyEqual(testCase, indexes(4),  7);
        end
        
        function testLowWaterIndexes(testCase)
            indexes = testCase.TimeSeries.lowWaterIndexes;
            
            verifyEqual(testCase, indexes(1),  2);
            verifyEqual(testCase, indexes(2),  4);
            verifyEqual(testCase, indexes(3),  6);
            verifyEqual(testCase, indexes(4),  8);
        end
        
        function testIsSlackOnly(testCase)
            verifyEqual(testCase, testCase.TimeSeries.isSlackOnly, 1);
        end
    end
end
