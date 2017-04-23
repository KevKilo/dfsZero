%{
dfeMerge_to_dfs0_main.m

Purpose: produce a single dfs0 file for each station datatype pair
            in a merged dataset file in the format produced by dfe
            It can process merged dataset files that contain one station
            datatype pair _or_ multiple station-datatypes

This code expects to find a list of merged dataset files in the
listFileName

The only hard coded attributes are the ones immediately below

Author: Kevin Kotun
Date:   April 11, 2017

%}

%location of the DHI mbin directory
matDir   = 'C:\MATLAB\' ;

%dfs0 file location
outDir   = 'C:\Users\KKotun\Documents\MATLAB\testOut\' ; 

%input text file directory
inputDir = 'C:\Users\KKotun\Documents\MATLAB\input\increment1\' ;

%output file prefix
outFilePrefix = 'testMultiple' ;

%list of file names to process MUST be located in inputDir!
listFileName = 'station.lst' ;
 
%load .NET dll modules
loadDotNet( matDir ) ;

listFileName = [ inputDir listFileName ] ;

if  exist( listFileName, 'file') == 0 
    error( 'I Can''t Find the List File: %s', listFileName ) ;
end
    
    listFile = fopen( listFileName, 'r'  ) ;
          
while ~feof( listFile ) 
    
    line = fgets( listFile );
     %remove eol chars
     line = regexprep( line, '\r\n|\n', '') ;

     dfeFileName = [ inputDir line ] ;
     populateDataSet( dfeFileName, outFilePrefix, outDir ) ;  
end

fclose( listFile ) ;



