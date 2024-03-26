function data_table = read_dataq_file(varargin)
%READ_DATAQ_FILE Reads recorded data from a dataq WDQ file
%   recorded_data = read_dataq_file(wdq_file_name,event_number)
%
%   Inputs:
%        wdq_file_name: path to WDQ file to be read
%        event_number:  Number of the event data to read
%   Output:
%        data_table: time table containing event data
%            Properties: 
%                Description: Event Comment
%                UserData.source_file
%                UserData.event_number
%
%   Returns the data for event, event_number,
%        marker_number = event_number-1;
%
%   Uses the .NET library dataq_library.dll, Dataq.dll and
%   Dataq.Files.Wdq.dll
%
%   Events in the WDQ file is the data between marker n-1 and marker n.
%   Put another way, Marker N represents the data for event N+1.

% Azim Jinha 2020-01-22

%% Parse inputs:
input_parser=inputParser;
input_parser.addRequired('wdq_file_name',@isfile);
input_parser.addOptional('event_number',1,@(numb) numb>=1);
input_parser.parse(varargin{:});
wdq_file_name = input_parser.Results.wdq_file_name;

% marker number is one less than input event number: M = E-1;
event_number = input_parser.Results.event_number;
marker_number = event_number-1;

dataq_obj = open_dataq_file(wdq_file_name);
sampleRate = dataq_obj.sampleRate;
current_marker = dataq_obj.markers(marker_number);

%% Get start time based on sample count (SC) , number of channels (N), and sample rate (SR)
% T = (SC/(N*SR))
%   SC: marker starts at the total number of samples for all channels
%    N: number of channels. The samples are divided into each sample
%   SR: sample rate in Hz (1/s).
channel_count = double(dataq_obj.channelCount);
current_sample = double(current_marker.Sample);
start_time_samples = current_sample/channel_count;
start_time_secs = seconds(start_time_samples/dataq_obj.sampleRate);

% readMarkerData returns a System.Double[,] array
% use 'double' to convert to a MATLAB double matrix
wdq_data = dataq_obj.readMarkerData(marker_number); 
matlab_data = double(wdq_data);

%% Create output time table
channel_names = string(dataq_obj.channelNames);
for i=1:length(channel_names)
    if channel_names(i).strlength==0
        channel_names(i)=replace(channel_names(i),"","Var" + string(num2str(i,'%02d')));
    end
end
data_table = array2timetable(matlab_data,'SampleRate',sampleRate,'StartTime',start_time_secs, ...
    'VariableNames',channel_names);
marker_comment = string(dataq_obj.comment(marker_number));
if ~isempty(marker_comment)
    data_table.Properties.Description = marker_comment;
end
data_table.Properties.UserData.source_file = wdq_file_name;
data_table.Properties.UserData.event_number = event_number;
data_table.Properties.UserData.marker_number = marker_number;
data_table.Properties.UserData.Comment = marker_comment;
end

