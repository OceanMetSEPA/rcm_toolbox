classdef GeneralTest < matlab.unittest.TestCase
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % $Workfile:   StatsTest.m  $
    % $Revision:   1.2  $
    % $Author:   ted.schlicke  $
    % $Date:   May 28 2014 13:04:08  $
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % These tests test the TimeSeries class using data from an HGAnalysis
    % worksheet for the fish farm at Vacasay, Loch Roag.
    %
    %   Vacasay_Bottom_HGdata_analysis_v7.11.xls
    %
    % The *expected* values in each of the tests are taken directly from
    % the values produced in the HGAnalysis spreadsheet in an effort to
    % demonstrate consistency with the spreadsheet tool.
    %
    % The raw data is loaded into each test via a "fixture" file which
    % contains the raw time, speed and direction data. Everything else is
    % derived by the Current.TimeSeries object.
    %
    %
    
    properties
        TimeSeries
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
            % Find the path to the RCM.Test directory
            testDir = what('RCM\+Test');
            
            % load the fixture data into the 'fixture' variable
            load([testDir.path,'\Fixtures\currents2.mat']);
            
            % Instantiate a TimeSeries object using fixture data (time,
            % speed, direction, pressure)
            testCase.TimeSeries = RCM.Current.TimeSeries.create(fixture.Time, ...
                fixture.Speed, ...
                fixture.Direction);
            
        end
    end
    
    methods (Test)

        % Check the first 3 datetime values to ensure object initialized
        % correctly
        %
        function testTimeVectorValues(testCase)
          % convert to datestr for clear comparison with spreadsheet 
          actSolution = datestr(testCase.TimeSeries.Time(1:3), 'dd/mm/yyyy HH:MM:SS');
          expSolution = [ '20/11/2012 09:00:00'
                          '20/11/2012 09:20:00'
                          '20/11/2012 09:40:00' ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution);
        end
        

        % Check the first 3 speed values to ensure object initialized
        % correctly
        %
        function testSpeedVectorValues(testCase)
          actSolution = testCase.TimeSeries.Speed(1:3);
          expSolution = [ 0.1139
                          0.1717
                          0.0908 ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.0001); % use tolerance since comparing floats
        end
        

        % Check the first 3 datetime values to ensure object initialized
        % correctly
        %
        function testDirectionVectorValues(testCase)
          actSolution = testCase.TimeSeries.Direction(1:3);
          expSolution = [ 148.45
                          147.39
                          182.08 ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.0001); % use tolerance since comparing floats
        end

        
        % Check the first 3 u values to ensure calculated correctly
        %
        function testUVectorValues(testCase)
          actSolution = testCase.TimeSeries.u(1:3);
          expSolution = [  0.059597313
                           0.092532188
                          -0.003295575 ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.0001); % use tolerance since comparing floats
        end

        
        % Check the first 3 v values to ensure calculated correctly
        %
        function testVVectorValues(testCase)
          actSolution = testCase.TimeSeries.v(1:3);
          expSolution = [  -0.097063743
                           -0.144632929
                           -0.090740174 ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.0001); % use tolerance since comparing floats
        end
        
        
        % Check the cumulative vector calculations.
        % Sufficient to check last vector since it is cumulative
        %
        function testCumulativeVector(testCase)
          cumVec = testCase.TimeSeries.cumulativeVector();
          
          actSolution = cumVec(end, :) / 1000.0; % convert to km for direct comparison with spreadsheet
          expSolution = [  24.04095618 -62.25742155 ]; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
        
        
        % Check the residual current speed
        %
        function testResidualSpeed(testCase)          
          actSolution = testCase.TimeSeries.ResidualSpeed; 
          expSolution = 0.0514476958587223; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
        
        
        % Check the residual current direction
        %
        function testResidualDirection(testCase)          
          actSolution = testCase.TimeSeries.ResidualDirection; 
          expSolution = 158.885729692693; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
        
        
        % Check the major axis direction
        %
        function testMajorAxisDirection(testCase)        
          actSolution = testCase.TimeSeries.MajorAxis; 
          expSolution = 140; % from HGAnalysis spreadsheet
          
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 5); % HGAnalysis round to nearest 5 degrees
        end 
        
        
        % Check the parallel amplitude
        %
        function testParallelAmplitude(testCase)        
          actSolution = testCase.TimeSeries.ParallelAmplitude; 
          expSolution = 0.130562846473602; % NOT from HGAnalysis spreadsheet
          
          % This differs slightly from HGAnalysis because HGAnalysis rounds
          % the major axis to the nearest 5 degree value. 
          %
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
        
        
        % Check the normal amplitude
        %
        function testNormalAmplitude(testCase)        
          actSolution = testCase.TimeSeries.NormalAmplitude; 
          expSolution =  0.031263894211630; % NOT from HGAnalysis spreadsheet
          
          % This differs slightly from HGAnalysis because HGAnalysis rounds
          % the major axis to the nearest 5 degree value. 
          %
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
        
        
        % Check the normal amplitude
        %
        function testAmplitudeAnisotropy(testCase)        
          actSolution = testCase.TimeSeries.AmplitudeAnisotropy; 
          expSolution = 4.176154307259487; % NOT from HGAnalysis spreadsheet
          
          % This differs slightly from HGAnalysis because HGAnalysis rounds
          % the major axis to the nearest 5 degree value. 
          %
          verifyEqual(testCase, actSolution, expSolution, 'AbsTol', 0.000001); % use tolerance since comparing floats
        end
    end
end
