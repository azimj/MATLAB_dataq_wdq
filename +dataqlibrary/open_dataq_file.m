function dataq_obj = open_dataq_file(wdq_file_name)
%OPEN_DATAQ_FILE open a dataq WDQ file
%  Usage
%     dataq_obj = dataqlibrary.open_dataq_file(WDQ_FILE_PATH) opens a WDQ
%     file with path WDQ_FILE_PATH.

%Azim J
%2024-03-28

arguments
    wdq_file_name {mustBeFile}
end

pn = fileparts(mfilename('fullpath'));
param_file = fullfile(pn,'settings.json');
fid=fopen(param_file,'r');
cln = onCleanup(@()fclose(fid));

fc = fread(fid,[1 inf],'uint8=>char');
params = jsondecode(fc);

dataq_library_file = params.DATAQ_WDQ_LIB;

%% Load C# .NET assembly
netAssembly = params.DATAQ_WDQ_LIB;

if ~isfile(netAssembly)
    netAssembly = which(dataq_library_file);
    if isempty(netAssembly) 
        disp(dataq_library_file);
        error("read_dataq_file:missing_dll", ...
            'Dataq Library DLL "dataq_library.dll" is not on MATLAB''s path\n Edit `settings.json` by adding the path to Dataq .NET SDK library file: `Dataq.Files.Wdq.dll`');
    end
end


%% Create dataq object for reading WDQ

warning('off','MATLAB:NET:AddAssembly:nameConflict');
cln2 = onCleanup(@()warning('on','MATLAB:NET:AddAssembly:nameConflict'));

NET.addAssembly(netAssembly);


[~, dataq_obj] = Dataq.Files.Wdq.Wdq.OpenRead(wdq_file_name);




