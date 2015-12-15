function result = runAll()
    result = matlab.unittest.TestResult
    testPackage = what('RCM/Test');
    testDirectories = dir(testPackage.path);
    
    % Filter out non-test directories
    testDirectories = testDirectories([testDirectories.isdir] & ...
        cellfun(@(x) ~isequal(x,'.'), {testDirectories.name}) & ...
        cellfun(@(x) ~isequal(x,'..'), {testDirectories.name}) & ...
        cellfun(@(x) ~isequal(x,'Fixtures'), {testDirectories.name}));
    
    for i = 1:length(testDirectories)
        dirPath = [testPackage.path, '\', testDirectories(i).name];
        namespace = strrep(testDirectories(i).name, '+', '');
        files   = dir(dirPath);
        
        files = files(~[files.isdir]);
        
        for f = 1:length(files)
            [~, filename, ~] = fileparts(files(f).name);
            disp(sprintf(['\n\n***** Running: ', filename, '*****\n\n']));
            eval(['result = run(RCM.Test.', namespace, '.', filename, ')']);
        end
    end
    
end

