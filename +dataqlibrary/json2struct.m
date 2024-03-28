function json_struct=json2struct(file_name,element_name)
% S=JSON.JSON2STRUCT(FILE_NAME,ELEMENT_NAME)
%   Reads a JSON encoded file and returns a struct representing the JSON
%   objects and returns the specified element `element_name`
%
%  Usage:
%      S=SON2STRUCT(FILE_NAME) Return all contents of the JSON file
%
% WARNING: row vectors (1xn) vectors will be read as a column (nx1).
% 
%
% See also:
%   jsondecode

% Azim Jinha 
% 2020-09-13

% Change Log
% 2021-02-17
%   * Added optional parameter to extract a sub-structre
% 2021-05-30
%    * simplified validation of file_name input
% 2024-03-28
%    * use argument block instead of inputParser

% Parse input and check that file exists
arguments
    file_name {isscalar,mustBeFile}
    element_name {isstring,ischar} = ""
end

fid=fopen(file_name);
cln=onCleanup(@()fclose(fid));

file_contents = fread(fid,[1 inf],'uint8=>char');
    
json_struct = jsondecode(file_contents);

if isfield(json_struct, element_name)
     json_struct = json_struct.(element_name);
end

