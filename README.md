# Dataq WDQ file library

Date: 2020-02-24
Author: Azim Jinha

Project: 
   Functions to extract data and meta data from windaq WDQ files.

List of Functions:
   READ_DATAQ_FILE
      data_table = read_dataq_file(wdq_file_name, marker_number)
      
         wdq_file_name: path to a WDQ file name
         marker_number: number of marker to read. Note:
            marker_number = event_number+1

   GET_DATAQ_MARKERS
       marker_table = get_dataq_markers(wdq_file_name)

Other locations:
   \\cinco

Change Log:
2020 02 24: Created functions to extract comments from markers (get_dataq_markers.m)
