function dataq_obj = open_dataq_file(varargin)

input_parser=inputParser;
input_parser.addRequired('wdq_file_name',@isfile);
input_parser.parse(varargin{:});
wdq_file_name = input_parser.Results.wdq_file_name;


%% Load C# .NET assembly
dataq_library_file = 'dataq_library.dll';
mpn = fileparts(mfilename('fullpath'));
netAssembly = fullfile(mpn,dataq_library_file);

if ~isfile(netAssembly)
    netAssembly = which(dataq_library_file);
    if isempty(netAssembly) 
        error("read_dataq_file:missing_dll","Dataq Library DLL 'dataq_library.dll' is not on MATLAB's path");
    end
end
NET.addAssembly(netAssembly);


%% Create dataq object for reading WDQ
dataq_obj = dataq_library.dataq;
dataq_obj.fileName = wdq_file_name;