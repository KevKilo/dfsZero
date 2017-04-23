
function returnValue = populateDataSet( inputFileName, outFilePrefix, outDir )

%{
Sample Input
This shows multiple stations on one line.
This code can also process a single station

#Merged Datasets Daily from 1999-01-01 to 2001-12-31
#Date|S333/flow|S334/flow
1999-01-01|252.840|0.000
1999-01-02|253.430|0.000
1999-01-03|254.600|0.000
1999-01-04|106.790|0.000
1999-01-05|0.000|0.000
1999-01-06|0.000|null
1999-01-07|0.000|0.000
1999-01-08|0.000|0.000
%}
 
inputFile = fopen( inputFileName, 'r' ) ;

if  exist( inputFileName, 'file') == 0 
    error( 'I Can''t Find the Input File: %s', inputFileName )
end

dataLineNo = 0 ;

while ~feof( inputFile ) 
    
    line = fgets( inputFile ) ;
    
    % get rid of annoying new line sequence.
    % below will work on linux ('\n') or windows ('\r\n')
    % b/c any machine should be able to create the data file
    % mac ('\r') is not included
   
    line = regexprep( line, '\r\n|\n', '') ;
    fields = regexp(line, '\|', 'split') ;
    numFields = length( fields ) ;
    
    % if there is only one field, then there is no delimiter
    % and the line is skipped
    
    if numFields <= 1
        continue  
    end
    
    %process the header line with station names and datatpes
    % date is the first field so num station is one less
    
    if ( numFields > 1 ) &&  ( strcmp( fields{ 1 }, '#Date' ) )
            numStations = ( numFields - 1 )  ;
              
        for i = 1 : numStations
            
            %stationID e.g.  S333/flow
            stationID{ i } = fields{ i+1 } ;   
            stationFields = regexp( stationID{ i }, '/', 'split' ) ;
            station{ i } = stationFields{ 1 } ;           
            dataType{ i } = stationFields{ 2 }  ;
            
        end

    else
 
    dataLineNo = dataLineNo + 1 ;
    dataFields = regexp( line, '\|', 'split' ) ;        
    dateVector{ dataLineNo } = dataFields{1} ;
    
    for i = 1 : numStations        
        if strcmp( dataFields( i +1 ), double('null'))
             dataFields( i + 1 ) = NaN ;
        end       
    end
        dataMtx( i, dataLineNo ) = str2double( dataFields{ i + 1 } ) ;
    end    
end

 startDate = dateVector{ 1 } ;
 endDate = dateVector{ length( dateVector ) } ;
    
       
   for i = 1 : numStations
 
       dataSet = dfsZeroTimeSeries( station{ i }, dataType{ i }, startDate, endDate, outFilePrefix, outDir )   ;
       
       dataValues = dataMtx( i, : ) ;                     
      
        dataSet = set_values( dataSet, dataValues ) ;
        dataSet = set_dates( dataSet, dateVector ) ;
       
        dataSet = padDataSet( dataSet ) ;
        outputDFS0( dataSet ) ;
       
   end 
    
   fclose( inputFile ) ;
   


    
       
        

       