classdef TideTest < matlab.unittest.TestCase
    % These tests are intended to test the functionality that is inherited
    % from the super class RCM.TimeSeries.Base
    
    properties
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
        end
        
    end
    
    methods (Test)
        
        % CONSTANTS

        function testSpringNeapDays(testCase)
          actSolution = 14.77;
          expSolution = RCM.Constants.Tide.SpringNeapAverageDays;
          
          verifyEqual(testCase, actSolution, expSolution);
        end

        function testSpringNeapSeconds(testCase)
          actSolution = 1276128.0;
          expSolution = RCM.Constants.Tide.SpringNeapAverageSeconds;
          
          verifyEqual(testCase, actSolution, expSolution);
        end

        function testSemiDiurnalHalfCycleSeconds(testCase)
          actSolution = 22350;
          expSolution = RCM.Constants.Tide.SemiDiurnalHalfCycleSeconds;
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        
    end
end
