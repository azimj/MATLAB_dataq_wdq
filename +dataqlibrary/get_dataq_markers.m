function data_table = get_dataq_markers(wdq_file_name, event_number)
%READ_DATAQ_FILE Reads recorded data from a dataq WDQ file
%   recorded_data = read_dataq_file(wdq_file_name,event_number)
%
%   Inputs:
%        wdq_file_name: path to WDQ file to be read
%        event_number:  Number of the event data to read
%   Output:
%        data_table: Table of marker meta data
%                     * event_number, duration,start_time, comment
%
%   Returns the data for event, event_number,
%        marker_number = event_number-1;
%
%   Uses the .NET library dataq_library.dll, Dataq.dll and
%   Dataq.Files.Wdq.dll
%
%   Events in the WDQ file is the data between marker n-1 and marker n.
%   Put another way, Marker N represents the data for event N+1.

% Azim Jinha 2020-01-24

% 2024-03-28
% * removed inputParser in favor of `arguments` block
% * update to use wdq .NET library directly

%% Parse inputs:
arguments
    wdq_file_name {mustBeFile}
    event_number {mustBeInteger} = -1
end

dataq_obj = dataqlibrary.open_dataq_file(wdq_file_name);
sampleRate = dataq_obj.Header.SampleRate;

marker_count = double(dataq_obj.Marks.Length);
channel_count = double(dataq_obj.Header.Channels);

%% initialize output table
markerData_struct(marker_count) = struct(...
    'EventTimes',   seconds(0), ...
    'EventLabels', "", ...
    'Comment',     "", ...
    'EventEnds',    seconds(-1), ...
    'EventNumber', 0);

%% Loop over Marks collecting comments
for iMark=1:marker_count
    
    current_marker = dataq_obj.Marks(iMark);
    current_sample = double(current_marker.Sample);
    start_time_samples = current_sample/channel_count;
    start_time_secs = seconds(start_time_samples/sampleRate);

    % if last mark use end of file sample for duration
    if iMark < marker_count
        next_mark_sample = double(dataq_obj.Marks(iMark+1).Sample);
    else
        next_mark_sample = double(dataq_obj.Header.DataSize_) /2;
    end

    end_time_sample = next_mark_sample/channel_count;
    end_time_secs = seconds(end_time_sample/sampleRate);

    markerData_struct(iMark).EventLabels = string(num2str(iMark,'Event %03d'));
    markerData_struct(iMark).EventTimes = start_time_secs;
    markerData_struct(iMark).EventEnds = end_time_secs;
    markerData_struct(iMark).EventNumber = iMark;
    cmt = string(dataq_obj.Marks(iMark).Comment);
    if isempty(cmt)
        cmt="";
    end
    markerData_struct(iMark).Comment = cmt;
end
%% Get start time based on sample count (SC) , number of channels (N), and sample rate (SR)
% T = (SC/(N*SR))
%   SC: marker starts at the total number of samples for all channels
%    N: number of channels. The samples are divided into each sample
%   SR: sample rate in Hz (1/s).

% data_table = struct2table(markerData);
tbl = struct2table(markerData_struct);
tbl.Comment = string(tbl.Comment);

el = tbl.Comment;
ev_ends = tbl.EventEnds;
ev_times = tbl.EventTimes;
tbl =tbl(:,"EventNumber");
ttt = table2timetable(tbl,"RowTimes",ev_times);
data_table = eventtable(ttt, ...
    "EventEnds",ev_ends, ...
    "EventLabels",el);
if event_number>0
    data_table = data_table(event_number,:);
end
end

