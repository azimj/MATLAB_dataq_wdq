# Dataq WDQ file library

Date: 2020-02-24
Author: Azim Jinha

## Project: 
   Functions to extract data and meta data from windaq WDQ files.

## List of Functions:
   READ_DATAQ_FILE
      data_table = read_dataq_file(wdq_file_name, marker_number)
      
         wdq_file_name: path to a WDQ file name
         marker_number: number of marker to read. Note:
            marker_number = event_number+1

   GET_DATAQ_MARKERS
       marker_table = get_dataq_markers(wdq_file_name)

## Dependencies

* [WinDaq](https://dataq.com/products/windaq/) waveform browser [https://dataq.com/products/windaq/]
* Dataq .NET controls
  * .NET SDK: https://www.dataq.com/products/sdk-dot-net/dotnet-class.html
  * URL: https://www.dataq.com/data-acquisition/software/developer-network/matlab.html
  * Documentation: https://www.dataq.com/resources/pdfs/misc/Using-DATAQ-DotNet-Controls-in-MATLAB.pdf
  * Example ZIP Download: https://www.dataq.com/resources/repository/DataqMatlabSDKExamples.zip

## Change Log:
2020 02 24: Created functions to extract comments from markers (get_dataq_markers.m)
