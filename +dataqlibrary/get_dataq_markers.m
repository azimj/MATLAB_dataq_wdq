function data_table = get_dataq_markers(varargin)
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

%% Parse inputs:
input_parser=inputParser;
input_parser.addRequired('wdq_file_name',@isfile);
input_parser.parse(varargin{:});
wdq_file_name = input_parser.Results.wdq_file_name;

dataq_obj = open_dataq_file(wdq_file_name);
sampleRate = dataq_obj.sampleRate;

marker_count = double(dataq_obj.markerCount);
channel_count = double(dataq_obj.channelCount);

for marker_number=0:marker_count-1
    event_number = marker_number+1;
    markerData(event_number).event_number = event_number;
    markerData(event_number).duration = dataq_obj.markerDuration(marker_number);
    current_marker = dataq_obj.markers(marker_number);
    current_sample = double(current_marker.Sample);
    start_time_samples = current_sample/channel_count;
    start_time_secs = seconds(start_time_samples/dataq_obj.sampleRate);
    markerData(event_number).start_time = start_time_secs;
    markerData(event_number).comment = string(dataq_obj.comment(marker_number));
end
%% Get start time based on sample count (SC) , number of channels (N), and sample rate (SR)
% T = (SC/(N*SR))
%   SC: marker starts at the total number of samples for all channels
%    N: number of channels. The samples are divided into each sample
%   SR: sample rate in Hz (1/s).

data_table = struct2table(markerData);


end

