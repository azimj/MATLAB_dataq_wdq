function data_table = read_dataq_file(wdq_file_name, event_number)
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

%2024-03-28 updates
% * Use `arguments` block instead of inputParser
% * Use Dataq's WDQ .NET library directly

%% Parse inputs:
arguments
    wdq_file_name {mustBeFile}
    event_number {isinteger,mustBePositive} = 1
end

dataq_obj = dataqlibrary.open_dataq_file(wdq_file_name);
sampleRate = dataq_obj.Header.SampleRate;
current_marker = dataq_obj.Marks(event_number);

%% Get start time based on sample count (SC) , number of channels (N), and sample rate (SR)
% T = (SC/(N*SR))
%   SC: marker starts at the total number of samples for all channels
%    N: number of channels. The samples are divided into each sample
%   SR: sample rate in Hz (1/s).
channel_count = double(dataq_obj.Header.Channels);
current_sample = double(current_marker.Sample);
start_time_samples = current_sample/channel_count;
start_time_secs = seconds(start_time_samples/sampleRate);

% readMarkerData returns a System.Double[,] array
% use 'double' to convert to a MATLAB double matrix
marker_comment = dataqlibrary.get_dataq_markers(wdq_file_name,event_number);
matlab_data = extract_channel_data(dataq_obj, marker_comment);


%% Get Channel Name
channel_names(channel_count) = "";
channel_units(channel_count) = "";
for i=1:length(channel_names)
    chn = string(dataq_obj.Channels(i).Annotation);
    if strlength(chn)==0
        chn=string(num2str(i,'chan_%02d'));
    end
    channel_names(i) = chn;

    ch_u = string(dataq_obj.Channels(i).Units);
    if strlength(ch_u) == 0
        ch_u = "Unknown";
    end
    channel_units(i) = ch_u;

end


%% Create data table
data_table = array2timetable(matlab_data,'SampleRate',sampleRate,'StartTime',start_time_secs, ...
    'VariableNames',channel_names);
data_table.Properties.VariableUnits = channel_units;


if ~isempty(marker_comment)
    data_table.Properties.Description = marker_comment.EventLabels;
    data_table.Properties.UserData.Comment = marker_comment.EventLabels;
end

data_table.Properties.UserData.source_file = wdq_file_name;
data_table.Properties.UserData.event_number = event_number;

end



function f_data = extract_channel_data(dataq_obj,mrk_data)

sr = double(dataq_obj.Header.SampleRate);
ev_duration = seconds(mrk_data.EventEnds - mrk_data.Time);
channel_count = double(dataq_obj.Header.Channels);
row_count = round(ev_duration * sr);
WWBSamplesSelected = row_count * channel_count;
Marker_Start_Sample = round(seconds(mrk_data.Time)*sr);

WWB_NArray = NET.createArray('System.Double', WWBSamplesSelected);
wdqFileSeekOrigin = System.IO.SeekOrigin.Begin;
try
    sample_loc = dataq_obj.Seek(Marker_Start_Sample,wdqFileSeekOrigin); %#ok<NASGU>
catch ME
    warning('Cannot seek file position.');
    throw(ME)
end

try
    dataq_obj.ReadEu(WWB_NArray, WWBSamplesSelected);
catch ME
    disp("***********")
    disp("Failed to read data from WDQ file at marker: " + mrk_data.EventLabels)
    disp("***********")
    throw(ME);
end

f_data = reshape(double(WWB_NArray),channel_count,[])';



end
