classdef ProfileTest < matlab.unittest.TestCase
    
    % These tests test the TimeSeries class using data from an HGAnalysis
    % worksheet for the fish farm at Vacasay, Loch Roag.
    %
    %
    % The raw data is loaded into each test via a "fixture" file which
    % contains the raw time, speed and direction data. Everything else is
    % derived by the TimeSeries object.
    %
    %
    
    properties
        FixtureData
        Profile
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
            % Find the path to the RCM.Test directory
            testDir = what('RCM\+Test');
            
            % load the fixture data into the 'fixture' variable
            load([testDir.path,'\profileFixture.mat'])
            
            % instantiate a TimeSeries object using fixture data (datetime,
            % speed and direction)
            testCase.FixtureData = fixture';
            testCase.Profile     = RCM.Profile(...
                'SiteName', 'Test Bay', ...
                'SiteID',   'TES1',...
                'Easting',  123456,...
                'Northing', 67890);
                        
            for i = 1:size(testCase.FixtureData, 1)
                testCase.Profile.addBin(testCase.FixtureData(i,1))
            end
        end
    end
    
    methods (Test)

        function checkConstructorSiteName(testCase)          
          verifyEqual(testCase, testCase.Profile.SiteName, 'Test Bay');
        end

        function checkConstructorEasting(testCase)
          verifyEqual(testCase, testCase.Profile.Easting, 123456);
        end

        function checkConstructorNorthing(testCase)          
          verifyEqual(testCase, testCase.Profile.Northing, 67890);
        end

        function checkConstructorSiteID(testCase)          
          verifyEqual(testCase, testCase.Profile.SiteID, 'TES1');
        end
        

       
    end
end
