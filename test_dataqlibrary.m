function tests = test_dataqlibrary
%TEST_DATAQLIBRARY Unit tests for the library: +dataqlibrary 
%    Usage: 
%           results = runtests(test_dataqlibrary)

%Azim J
%2024-03-28

tests = functiontests(localfunctions);

end

%% Setup
function setupOnce(testCase)
    pn = fileparts(mfilename('fullpath'));
    curpath = pwd;
    oncln = onCleanup(@()cd(curpath));
    cd(pn)
    testCase.TestData.wdqFile = 'testData.wdq';
    disp(pwd)
end

%% Tests
function test_dataqtests(testCases) %#ok<*INUSD>
    disp('running tests');
end

function test_json2struct(testCase)
    e=struct(...
        "string_var",'string', ...
        "scalar",1, ...
        "row_vec",1:4, ...
        "col_vec",(1:4)');
    j = dataqlibrary.json2struct('test_json.json');
    testCase.assertEqual(j,e,'json was not interpreted');
    f = dataqlibrary.json2struct('test_json.json','scalar');
    testCase.assertEqual(f,1,'json2struct could not read field');
    
end

function test_open_dataq_file(testCase)
    
    data_obj = dataqlibrary.open_dataq_file(testCase.TestData.wdqFile);

end

function test_read_marks(testCase)
    data_obj = dataqlibrary.get_dataq_markers(testCase.TestData.wdqFile); %#ok<*NASGU>
end

function test_read_dataq_file(testCase)
    dt = dataqlibrary.read_dataq_file(testCase.TestData.wdqFile,1);
end