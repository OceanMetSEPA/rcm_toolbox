classdef ConstructorTest < matlab.unittest.TestCase
    
    properties
        Time
        Speed
        Direction
        Pressure
        Easting
        Northing
        HeightAboveBed
    end
    
    methods(TestMethodSetup)
        
        function setup(testCase)
            % Find the path to the RCM.Test directory
            testDir = what('RCM\+Test');
            
            % load the fixture data into the 'fixture' variable
            load([testDir.path,'\Fixtures\currents1.mat']);
            
            testCase.Time      = fixture.Time;
            testCase.Speed     = fixture.Speed;
            testCase.Direction = fixture.Direction;
            testCase.Pressure  = fixture.Pressure;
            testCase.Easting   = fixture.Easting;
            testCase.Northing  = fixture.Northing;
            testCase.HeightAboveBed  = fixture.HeightAboveBed;
        end
    end
    
    methods (Test)
        
        function testConstructor(testCase)
            ts = RCM.Current.TimeSeries;
            
            verifyEqual(testCase, class(ts), 'RCM.Current.TimeSeries');
            verifyEqual(testCase, ts.length, 0);
        end

        function testConstructorAndPropertyAssignment(testCase)
            ts = RCM.Current.TimeSeries;
            ts.Time      = testCase.Time;
            ts.Speed     = testCase.Speed;
            ts.Direction = testCase.Direction;
            
            verifyEqual(testCase, ts.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.Speed(1),    0.1156, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(100),  0.2197, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(1000), 0.0512, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.u(1),    0.108208482331425,  'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(100),  0.0618464705585274, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(1000), 0.0130010501524141, 'AbsTol', 0.0000001);
            
            % These are set by the get.Property method. Might change this.            
            verifyFalse(testCase, isempty(ts.u));
            verifyFalse(testCase, isempty(ts.v));
            
            % These are set by the calculateHarmonics method, so should not
            % be set here.
            verifyTrue(testCase, isempty(ts.uTidal));
            verifyTrue(testCase, isempty(ts.vTidal));
            
            verifyEqual(testCase, ts.length, 3368);
        end

        function testCreateConstructor(testCase)
            ts = RCM.Current.TimeSeries.create(testCase.Time, testCase.Speed, testCase.Direction);
                        
            verifyEqual(testCase, class(ts), 'RCM.Current.TimeSeries');
            
            verifyEqual(testCase, ts.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.Speed(1),    0.1156, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(100),  0.2197, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(1000), 0.0512, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.u(1),    0.108208482331425,  'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(100),  0.0618464705585274, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(1000), 0.0130010501524141, 'AbsTol', 0.0000001);
            
            % These are set by the create method.            
            verifyFalse(testCase, isempty(ts.u));
            verifyFalse(testCase, isempty(ts.v));
            
            % These are set by the calculateHarmonics method, so should not
            % be set here.
            verifyTrue(testCase, isempty(ts.uTidal));
            verifyTrue(testCase, isempty(ts.vTidal));
            
            verifyEqual(testCase, ts.length, 3368);
        end

        function testCreateFromComponentsConstructor(testCase)
            % Create time series to get u and v from.
            ts = RCM.Current.TimeSeries.create(testCase.Time, testCase.Speed, testCase.Direction);
            u = ts.u;
            v = ts.v;
            
            uvts = RCM.Current.TimeSeries.createFromComponents(testCase.Time, u, v);
            
            verifyEqual(testCase, class(uvts), 'RCM.Current.TimeSeries');
            
            verifyEqual(testCase, uvts.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, uvts.Speed(1),    0.1156, 'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.Speed(100),  0.2197, 'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.Speed(1000), 0.0512, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, uvts.u(1),    0.108208482331425,  'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.u(100),  0.0618464705585274, 'AbsTol', 0.0000001);
            verifyEqual(testCase, uvts.u(1000), 0.0130010501524141, 'AbsTol', 0.0000001);
            
            % These are set by the create method.            
            verifyFalse(testCase, isempty(uvts.u));
            verifyFalse(testCase, isempty(uvts.v));           
            verifyFalse(testCase, isempty(uvts.Speed));
            verifyFalse(testCase, isempty(uvts.Direction));
            
            % These are set by the calculateHarmonics method, so should not
            % be set here.
            verifyTrue(testCase, isempty(uvts.uTidal));
            verifyTrue(testCase, isempty(uvts.vTidal));
            
            verifyEqual(testCase, uvts.length, 3368);
        end
        
        function testFromStructConstructor(testCase)
            ts = RCM.Current.TimeSeries.fromStruct(testCase);
                        
            verifyEqual(testCase, class(ts), 'RCM.Current.TimeSeries');
            
            verifyEqual(testCase, ts.Time(1),    735670.698784722, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(100),  735672.073819444, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Time(1000), 735684.573831019, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.Speed(1),    0.1156, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(100),  0.2197, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.Speed(1000), 0.0512, 'AbsTol', 0.0000001);
            
            verifyEqual(testCase, ts.u(1),    0.108208482331425,  'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(100),  0.0618464705585274, 'AbsTol', 0.0000001);
            verifyEqual(testCase, ts.u(1000), 0.0130010501524141, 'AbsTol', 0.0000001);
            
            % These are set by the create method.            
            verifyFalse(testCase, isempty(ts.u));
            verifyFalse(testCase, isempty(ts.v));
            
            % These are set by the calculateHarmonics method, so should not
            % be set here.
            verifyTrue(testCase, isempty(ts.uTidal));
            verifyTrue(testCase, isempty(ts.vTidal));
            
            verifyEqual(testCase, ts.length, 3368);
        end
%         
    end
end
