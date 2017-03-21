classdef TimeSeriesTest < matlab.unittest.TestCase
    % These tests are intended to test the functionality that is inherited
    % from the super class RCM.TimeSeries.Base
    
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
            % height)
            testCase.TimeSeries = RCM.WaterLevel.TimeSeries.create(fixture.Time, fixture.Pressure);
        end
    end
    
    methods (Test)
        
        % INSTANCE METHODS
        
        function testClass(testCase)
            verifyTrue(testCase, isa(testCase.TimeSeries,'RCM.WaterLevel.TimeSeries'));
        end
        
        function testLength(testCase)
          actSolution = 3368;
          expSolution = testCase.TimeSeries.length;
          
          verifyEqual(testCase, actSolution, expSolution);
        end

        function testStartTime(testCase)
          actSolution = 735670.698784722;
          expSolution = testCase.TimeSeries.startTime;
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001);
        end
        
        function testEndTime(testCase)
          actSolution = 735717.462719907;
          expSolution = testCase.TimeSeries.endTime;
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001);
        end
        
        function testLengthDays(testCase)
          actSolution = 46.763935185;
          expSolution = testCase.TimeSeries.lengthDays;
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.001);
        end
        
        function testResolution(testCase)
          actSolution = 1200;
          expSolution = testCase.TimeSeries.timeIntervalSeconds;
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.01);
        end
        
        function testDataPointsPerSemiDiurnalHalfCycle(testCase)
          actSolution = 18;
          expSolution = testCase.TimeSeries.dataPointsPerSemiDiurnalHalfCycle;
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testDataPointsPerSpringNeapCycle(testCase)
          actSolution = 1063;
          expSolution = testCase.TimeSeries.dataPointsPerSpringNeapCycle;
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testSpringNeapCycleCount(testCase)
          actSolution = 3.166143208202706;
          expSolution = testCase.TimeSeries.springNeapCycleCount;
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.0000001);
        end
        
        function testFirstSpringNeapIndexes(testCase)
          % Get indexes of all data points within first spring-neap cycle
          actSolution = 1:1064;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes;
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testSecondSpringNeapIndexes(testCase)
          % Get indexes of all data points within second spring-neap cycle
          actSolution = 1064:2127;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes('cycle', 2);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testThirdSpringNeapIndexes(testCase)
          % Get indexes of all data points within third spring-neap cycle
          actSolution = 2127:3190;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes('cycle', 3);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testFirstSpringNeapIndexesWithOffset(testCase)
          % Get indexes of all data points within first spring-neap cycle
          % with offset from the start
          actSolution = 101:1164;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes('offset', 100);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testSecondSpringNeapIndexesWithOffset(testCase)
          % Get indexes of all data points within second spring-neap cycle
          % with offset from the start
          actSolution = 1164:2227;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes('cycle', 2, 'offset', 100);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testThirdSpringNeapIndexesWithOffset(testCase)
          % Get indexes of all data points within third spring-neap cycle
          % with offset from the start
          actSolution = 2227:3290;
          expSolution = testCase.TimeSeries.springNeapCycleIndexes('cycle', 3, 'offset', 100);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testSpringNeapIndexesTooFewCycles(testCase)
          % Requested number of cycles is too long for timeseries
          
          try
              testCase.TimeSeries.springNeapCycleIndexes('cycle', 6);
              verifyTrue(testCase, false, 'No error raised.')
          catch Err
              verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
          end
        end
        
        function testSpringNeapIndexesOffsetTooLarge(testCase)
          % Requested number of cycles plus offset is too long for timeseries
          
          try
              testCase.TimeSeries.springNeapCycleIndexes('cycle', 3, 'offset', 200);
              verifyTrue(testCase, false, 'No error raised.')
          catch Err
              verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
          end
        end
        
        function testClosestRecordIndexValue(testCase)
          % Test value (first output)
          actSolution = 500;
          expSolution = testCase.TimeSeries.closestRecordToTimeIndex(735677.6293865);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClosestRecordIndexBoolean(testCase)
          % test boolean (second output)
          actSolution = 1;
          [~, expSolution] = testCase.TimeSeries.closestRecordToTimeIndex(735677.6293865);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClosestRecordIndexValueIfBeforeTimeSeries(testCase)
          % requested time is before timeseries
          actSolution = 1;
          expSolution = testCase.TimeSeries.closestRecordToTimeIndex(735669);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClosestRecordIndexBooleanIfBeforeTimeSeries(testCase)
          % requested time is before timeseries
          actSolution = 0;
          [~, expSolution] = testCase.TimeSeries.closestRecordToTimeIndex(735669);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClosestRecordIndexValueIfAfterTimeSeries(testCase)
          % requested time is after timeseries
          actSolution = 3368;
          expSolution = testCase.TimeSeries.closestRecordToTimeIndex(735718);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClosestRecordIndexBooleanIfAfterTimeSeries(testCase)
          % requested time is after timeseries
          actSolution = 0;
          [~, expSolution] = testCase.TimeSeries.closestRecordToTimeIndex(735718);
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
        function testClearDerivedPropertiesAll(testCase)
          % No properties derived using get.Property methods on this class
        end
        
        function testClearDerivedPropertiesWithException(testCase)
          % No properties derived using get.Property methods on this class
        end
        
        function testClone(testCase)
            clonedTimeSeries = testCase.TimeSeries.clone;
            
            % make sure clone is correct class
            verifyTrue(testCase, isa(clonedTimeSeries, 'RCM.WaterLevel.TimeSeries'));
            
            % Make sure clone is different object
            verifyFalse(testCase, eq(testCase.TimeSeries, clonedTimeSeries));
            
            % check values are the same
            verifyEqual(testCase, testCase.TimeSeries.Time(100),     clonedTimeSeries.Time(100));
            verifyEqual(testCase, testCase.TimeSeries.Height(500),   clonedTimeSeries.Height(500));
            verifyEqual(testCase, testCase.TimeSeries.isSlack(1000), clonedTimeSeries.isSlack(1000));
            verifyEqual(testCase, testCase.TimeSeries.length,        clonedTimeSeries.length);
        end
        
        function testTruncateByIndexNoOptions(testCase)
            % This should do nothing to the object
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByIndex;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
        end
%         
        function testTruncateByIndexStartIndex(testCase)
            % Truncate from start only
            
            startIndex = 500;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735677.629386574;
            newEndTime   = 735717.462719907;
            newLength    = 3368 - (startIndex - 1);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByIndex('startIndex', startIndex);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1), newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length, newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateByIndexEndIndex(testCase)
            % Truncate from end only
            
            endIndex = 3000;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735670.698784722;
            newEndTime   = 735712.351597222;
            newLength    = endIndex;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1), oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length, oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByIndex('endIndex', endIndex);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1), newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length, newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateByIndexStartAndEndIndex(testCase)
            % Truncate start and end
            
            startIndex = 500;
            endIndex = 3000;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735677.629386574;
            newEndTime   = 735712.351597222;
            newLength    = endIndex - (startIndex - 1);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByIndex('startIndex', startIndex, 'endIndex', endIndex);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateByTimeNoOptions(testCase)
            % This should do nothing to the object
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByTime;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
        end
        
        function testTruncateByTimeStartIndex(testCase)
            % Truncate from start only
            
            startTime = 735677.629386574;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735677.629386574;
            newEndTime   = 735717.462719907;
            newLength    = 3368 - (500 - 1);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByTime('startTime', startTime);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateByTimeEndIndex(testCase)
            % Truncate from end only
            
            endTime = 735712.351597222;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735670.698784722;
            newEndTime   = 735712.351597222;
            newLength    = 3000;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByTime('endTime', endTime);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateByTimeStartAndEndIndex(testCase)
            % Truncate from start and end
            
            startTime = 735677.629386574;
            endTime   = 735712.351597222;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735677.629386574;
            newEndTime   = 735712.351597222;
            newLength    = 3000 - (500 - 1);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateByTime('startTime', startTime, 'endTime', endTime);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateToDays(testCase)
            % Requested number of days is within timeseries
            
            days = 20;
            
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735670.698784722;
            newEndTime   = 735690.698831019;
            newLength    = 1441;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateToDays(20);
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testTruncateToDaysDataTooShort(testCase)
          % Requested number of days is longer than time series
          
          try
             testCase.TimeSeries.truncateToDays(50);
             verifyTrue(testCase, false, 'No error raised.')
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
          end
        end
        
        function testTruncateSpringNeapCycle(testCase)
                        
            oldStartTime = 735670.698784722;
            oldEndTime   = 735717.462719907;
            oldLength    = 3368;
            
            newStartTime = 735670.698784722;
            newEndTime   = 735685.4627199074;
            newLength    = 1064;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   oldStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), oldEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     oldLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), oldLength);
            
            testCase.TimeSeries.truncateToSpringNeapCycle;
            
            verifyEqual(testCase, testCase.TimeSeries.Time(1),   newStartTime, 'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.Time(end), newEndTime,   'AbsTol', 0.000001);
            verifyEqual(testCase, testCase.TimeSeries.length,    newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.Height),      newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isSlack),     newLength);
            verifyEqual(testCase, length(testCase.TimeSeries.isHighWater), newLength);
        end
        
        function testRepeatTwoCycles(testCase)
           rep = testCase.TimeSeries.clone;
           rep.repeat(2);
           
           verifyEqual(testCase, rep.length, testCase.TimeSeries.length*2);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),   testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(1+testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(1)+testCase.TimeSeries.lengthDays+testCase.TimeSeries.timeIntervalSeconds/(60*60*24), 'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(100+testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(100)+testCase.TimeSeries.lengthDays+testCase.TimeSeries.timeIntervalSeconds/(60*60*24), 'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that second cycle has same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),                              testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100),                            testCase.TimeSeries.Height(100));
           verifyEqual(testCase, rep.Height(1+testCase.TimeSeries.length),   testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100+testCase.TimeSeries.length), testCase.TimeSeries.Height(100));
        end
        
        function testRepeatFourCycles(testCase)
           rep = testCase.TimeSeries.clone;
           rep.repeat(4);
           
           verifyEqual(testCase, rep.length, testCase.TimeSeries.length*4);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1), testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(1+3*testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(1)+3*testCase.TimeSeries.lengthDays+3*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), 'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(100+3*testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(100)+3*testCase.TimeSeries.lengthDays+3*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), 'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that later cycles have same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1), testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100), testCase.TimeSeries.Height(100));
           verifyEqual(testCase, rep.Height(1+2*testCase.TimeSeries.length), testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100+2*testCase.TimeSeries.length), testCase.TimeSeries.Height(100));
           verifyEqual(testCase, rep.Height(1+3*testCase.TimeSeries.length), testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100+3*testCase.TimeSeries.length), testCase.TimeSeries.Height(100));
        end
        
        function testRepeatTenCycles(testCase)
           rep = testCase.TimeSeries.clone;
           rep.repeat(10);
           
           verifyEqual(testCase, rep.length, testCase.TimeSeries.length*10);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1), testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(1+9*testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(1)+9*testCase.TimeSeries.lengthDays+9*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), ...
               'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(100+9*testCase.TimeSeries.length), ...
               testCase.TimeSeries.Time(100)+9*testCase.TimeSeries.lengthDays+9*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), ...
               'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that later cycles have same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),                                testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100),                              testCase.TimeSeries.Height(100));
           verifyEqual(testCase, rep.Height(1+5*testCase.TimeSeries.length),   testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100+5*testCase.TimeSeries.length), testCase.TimeSeries.Height(100));
           verifyEqual(testCase, rep.Height(1+9*testCase.TimeSeries.length),   testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100+9*testCase.TimeSeries.length), testCase.TimeSeries.Height(100));
        end
        
        function testRepeatTwoCyclesWithRepeatLength(testCase)
           rep          = testCase.TimeSeries.clone;
           cycles       = 2;
           repeatLength = 100;
           rep.repeat(cycles, 'repeatLength', repeatLength);
           
           verifyEqual(testCase, rep.length, cycles*repeatLength);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),  testCase.TimeSeries.Time(1));
           verifyEqual(testCase, rep.Time(50), testCase.TimeSeries.Time(50));
           verifyEqual(testCase, rep.Time(1+repeatLength), ...
               testCase.TimeSeries.Time(1)+repeatLength*testCase.TimeSeries.timeIntervalSeconds/(60*60*24),...
               'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(100+repeatLength), ...
               testCase.TimeSeries.Time(100)+repeatLength*testCase.TimeSeries.timeIntervalSeconds/(60*60*24),...
               'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that second cycle has same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),               testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50),              testCase.TimeSeries.Height(50));
           verifyEqual(testCase, rep.Height(1+repeatLength),  testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50+repeatLength), testCase.TimeSeries.Height(50));
        end
        
        function testRepeatTwoCyclesWithOffset(testCase)
           rep          = testCase.TimeSeries.clone;
           cycles       = 2;
           repeatLength = 100;
           offset       = 20;
           rep.repeat(cycles, 'repeatLength', repeatLength, 'offset', offset);
           
           verifyEqual(testCase, rep.length, cycles*repeatLength);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),  testCase.TimeSeries.Time(1));
           verifyEqual(testCase, rep.Time(50), testCase.TimeSeries.Time(50));
           verifyEqual(testCase, rep.Time(1+repeatLength), ...
               testCase.TimeSeries.Time(1)+repeatLength*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), ...
               'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(100+repeatLength), ...
               testCase.TimeSeries.Time(100)+repeatLength*testCase.TimeSeries.timeIntervalSeconds/(60*60*24), ...
               'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that second cycle has same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),               testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50),              testCase.TimeSeries.Height(50));
           verifyEqual(testCase, rep.Height(1+repeatLength),  testCase.TimeSeries.Height(1+offset));
           verifyEqual(testCase, rep.Height(50+repeatLength), testCase.TimeSeries.Height(50+offset));
        end
        
        function testRepeatTenCyclesWithOffset(testCase)
           rep          = testCase.TimeSeries.clone;
           cycles       = 10;
           repeatLength = 100;
           offset       = 20;
           rep.repeat(cycles, 'repeatLength', repeatLength, 'offset', offset);
           
           verifyEqual(testCase, rep.length, repeatLength*cycles);
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),  testCase.TimeSeries.Time(1));
           verifyEqual(testCase, rep.Time(50), testCase.TimeSeries.Time(50));
           verifyEqual(testCase, rep.Time(1+5*repeatLength), ...
               testCase.TimeSeries.Time(1)+5*repeatLength*(testCase.TimeSeries.timeIntervalSeconds/(60*60*24)), ...
               'AbsTol', 0.000001);
           verifyEqual(testCase, rep.Time(50+9*repeatLength), ...
               testCase.TimeSeries.Time(50)+9*repeatLength*(testCase.TimeSeries.timeIntervalSeconds/(60*60*24)), ...
               'AbsTol', 0.000001);
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that later cycles have corrent values, alternating
           % between repeated but offset samples of the original time series         
           verifyEqual(testCase, rep.Height(1),                 testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50),                testCase.TimeSeries.Height(50));        % normal cycle
           verifyEqual(testCase, rep.Height(1+repeatLength),    testCase.TimeSeries.Height(1+offset));  % offset cycle
           verifyEqual(testCase, rep.Height(50+repeatLength),   testCase.TimeSeries.Height(50+offset)); % offset cycle
           verifyEqual(testCase, rep.Height(1+2*repeatLength),  testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50+2*repeatLength), testCase.TimeSeries.Height(50));        % normal cycle
           verifyEqual(testCase, rep.Height(1+3*repeatLength),  testCase.TimeSeries.Height(1+offset));  % offset cycle
           verifyEqual(testCase, rep.Height(50+3*repeatLength), testCase.TimeSeries.Height(50+offset)); % offset cycle
           verifyEqual(testCase, rep.Height(1+4*repeatLength),  testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50+4*repeatLength), testCase.TimeSeries.Height(50));        % normal cycle
           verifyEqual(testCase, rep.Height(1+5*repeatLength),  testCase.TimeSeries.Height(1+offset));  % offset cycle
           verifyEqual(testCase, rep.Height(50+5*repeatLength), testCase.TimeSeries.Height(50+offset)); % offset cycle
           verifyEqual(testCase, rep.Height(1+8*repeatLength),  testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50+8*repeatLength), testCase.TimeSeries.Height(50));        % normal cycle
        end
        
        function testRepeatWithNonWholeNumberOfCycles(testCase)
           % Number of cycles is not a whole number
            
           rep    = testCase.TimeSeries.clone;
           cycles = 2.5;
                      
          try
             rep.repeat(cycles);
             verifyTrue(testCase, false, 'No error raised.');
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InvalidArgument')
           end
        end
        
        function testRepeatWithRepeatLengthTooLarge(testCase)
           % Requested repeat length is longer than original timeseries
           
           rep          = testCase.TimeSeries.clone;
           cycles       = 2;
           repeatLength = testCase.TimeSeries.length+1;
                      
           try
             rep.repeat(cycles, 'repeatLength', repeatLength);
             verifyTrue(testCase, false, 'No error raised.');
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
           end
        end
        
        function testRepeatWithOffsetTooLarge(testCase)
           % Requested repeat length plus offset is too large
           
           rep          = testCase.TimeSeries.clone;
           cycles       = 2;
           repeatLength = testCase.TimeSeries.length-1;
           offset       = 2;
           
           try
             rep.repeat(cycles, 'repeatLength', repeatLength, 'offset', offset);
             verifyTrue(testCase, false, 'No error raised.');
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
           end
        end
        
        function testRepeatForDaysLonger(testCase)
           % Requested number of days is longer than original timeseries
           
           rep = testCase.TimeSeries.clone;
           rep.repeatForDays(100);
           
           verifyEqual(testCase, rep.lengthDays, 100, 'AbsTol', 0.0002); % within 20 seconds
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),   testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(end), ...
               testCase.TimeSeries.Time(1)+100, ...
               'AbsTol', 0.0002); % within 20 seconds
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that other cycles have same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),                               testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50),                              testCase.TimeSeries.Height(50));
           verifyEqual(testCase, rep.Height(1+testCase.TimeSeries.length),    testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50+testCase.TimeSeries.length),   testCase.TimeSeries.Height(50));
           verifyEqual(testCase, rep.Height(1+2*testCase.TimeSeries.length),  testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(50+2*testCase.TimeSeries.length), testCase.TimeSeries.Height(50));
        end
        
        function testRepeatForDaysShorter(testCase)
           % Requested number of days is shorter than original time series
           
           rep = testCase.TimeSeries.clone;
           rep.repeatForDays(30);
           
           verifyEqual(testCase, rep.lengthDays, 30, 'AbsTol', 0.0002); % within 20 seconds
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),   testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(end), ...
               testCase.TimeSeries.Time(1)+30, ...
               'AbsTol', 0.0002); % within 20 seconds
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           % Check that values are just truncated, not repeated
           verifyEqual(testCase, rep.Height(1),   testCase.TimeSeries.Height(1));
           verifyEqual(testCase, rep.Height(100), testCase.TimeSeries.Height(100));
           
           Day30Idx = testCase.TimeSeries.closestRecordToTimeIndex(rep.endTime);
           verifyEqual(testCase, rep.Height(end), testCase.TimeSeries.Height(Day30Idx));
        end
        
        function testRepeatSpringNeap(testCase)
           % Requested number of days is longer than original timeseries
           
           rep = testCase.TimeSeries.clone;
           rep.repeatSpringNeapCycle(100);
           
           verifyEqual(testCase, rep.lengthDays, 100, 'AbsTol', 0.0002); % within 20 seconds
           
           % Check that time vector is advanced not repeated
           verifyEqual(testCase, rep.Time(1),   testCase.TimeSeries.Time(1))
           verifyEqual(testCase, rep.Time(100), testCase.TimeSeries.Time(100))
           verifyEqual(testCase, rep.Time(end), ...
               testCase.TimeSeries.Time(1)+100, ...
               'AbsTol', 0.0002); % within 20 seconds
           
           % The new time vector has some variability in resolution due to
           % rounding errors. Check that this is minimal - that there is
           % less than 10 seconds difference between the minimum and
           % maximum time intervals.
           timeDiffs = unique(abs(diff(rep.Time)));
           verifyLessThan(testCase, max(timeDiffs)-min(timeDiffs), 10/(24*60*60));
           
           springNeapLength = testCase.TimeSeries.dataPointsPerSpringNeapCycle;
           offset           = round(floor((RCM.Constants.Tide.SemiDiurnalHalfCycleSeconds*RCM.Constants.Tide.SemiDiurnalHalfCycleSpringNeapExcessFactor)/testCase.TimeSeries.timeIntervalSeconds));

           % Check that other cycles have same values as first (i.e. is
           % repeated)
           verifyEqual(testCase, rep.Height(1),                     testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50),                    testCase.TimeSeries.Height(50));        % normal cycle
           verifyEqual(testCase, rep.Height(1+springNeapLength),    testCase.TimeSeries.Height(1+offset));  % offset cycle
           verifyEqual(testCase, rep.Height(50+springNeapLength),   testCase.TimeSeries.Height(50+offset)); % offset cycle
           verifyEqual(testCase, rep.Height(1+2*springNeapLength),  testCase.TimeSeries.Height(1));         % normal cycle
           verifyEqual(testCase, rep.Height(50+2*springNeapLength), testCase.TimeSeries.Height(50));        % normal cycle
        end
        
        function testReatSpringNeapRequiredDaysShorterThanCycle(testCase)
           % Requested number of days is shorter than spring neap cycle
           
           rep = testCase.TimeSeries.clone;           
           
           try
             rep.repeatSpringNeapCycle(10);
             verifyTrue(testCase, false, 'No error raised.');
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InvalidArgument')
           end
        end
        
        function testReatSpringNeapTimeSeriesShorterThanCycle(testCase)
           % Time series length is shorter than spring neap cycle 
           
           rep = testCase.TimeSeries.clone;
           rep.truncateToDays(13);
           
           try
             rep.repeatSpringNeapCycle(50);
             verifyTrue(testCase, false, 'No error raised.');
          catch Err
             verifyEqual(testCase, Err.identifier, 'RCM:TimeSeries:InsufficientData')
           end
        end
        
    end
end
