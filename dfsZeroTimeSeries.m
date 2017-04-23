
classdef dfsZeroTimeSeries
    properties
        dfs0FileName
        outFilePrefix
        title
        stationName
        dataType
        dataTypeAbrev
        startDate
        endDate
        globalStartDate = [ 1965 1 1 0 0 0 ]
        globalEndDate = [ 2016, 12, 31, 0, 0, 0 ]
        globalLength
        units
        utmx
        utmy
        gridgse
        length
        dates
        values
        globalDates
        globalDateVec
        globalValues
        dataSetInteger
        timeStep = [ 0 0 1 0 0 0 ]
        deleteValue = -1.0e-35
        years           % vector of unique years
        yearDays        % vector of num days for each year 
        yearDaysCum     % vector a yearDays accumulated
        monthDays       % vector of days in each month
        monthDaysCum    % vector of days in each month accumulated
        
    end
    
    methods
        function  obj = dfsZeroTimeSeries( stationName, dataType, startDate, endDate, outFilePrefix, outDir )
                    
            if ischar( stationName )
                obj.stationName = stationName ;
            else
                error( 'StationName MUST be a char string' ) ;
            end
            
            if ischar( stationName )
                obj.title = stationName ;
            else
                error( 'Title MUST be a char string' ) ;
            end
                        
            if ischar( dataType )              
                switch upper( dataType )
                    case 'FLOW'
                        obj.dataType = 'Discharge' ;
                    case 'STAGE'
                        obj.dataType = 'Water Level' ;
                    case 'RAIN' 
                        obj.dataType = 'Rain' ;
                end
                
                switch obj.dataType
                case 'Discharge'
                    obj.units = 'ft^3/s' ;
                    obj.dataTypeAbrev = '_Q' ;
                case 'Water Level'
                    obj.units = 'ft' ;
                    obj.dataTypeAbrev = '' ;
                case 'Rain'
                    obj.units = 'inches' ;
                end 
           
            else
                error( 'dataType must be a character string' ) ;
            end
            
            if ischar( startDate ) 
                obj.startDate = datevec( startDate ) ;
            else
                error( 'startDate must be iso date as char, e.g. yyyy-mm-dd' ) ;
            end   
            
            if ischar( endDate ) 
                obj.endDate = datevec( endDate ) ;
            else
                error( 'endDate must be iso date as char, e.g. yyyy-mm-dd' )            
            end
   
             if ischar( outFilePrefix ) 
                obj.outFilePrefix = outFilePrefix ;
            else
                error( 'Prefix for dfs0 file must be a char, e.g. modelRun1' )            
             end
                          
             outFileName = strcat( obj.outFilePrefix, '_', obj.stationName, obj.dataTypeAbrev, '.dfs0') ;
             obj.dfs0FileName = fullfile( outDir, outFileName ) ;
      
            if( exist( obj.dfs0FileName, 'file' ) == 2 )
                fprintf( 'DFS0 file exists, replacing: %s\n', obj.dfs0FileName ) ;
                delete( obj.dfs0FileName ) ;
            else
                fprintf( 'Creating dfs0 file %s\n', obj.dfs0FileName ) ;
            end
         
            obj.length = datenum( obj.endDate ) - datenum( obj.startDate ) + 1 ;
            obj.globalLength = datenum( obj.globalEndDate ) - ...
                                datenum( obj.globalStartDate ) + 1 ;
                            
            globalDatesInts = linspace( datenum( obj.globalStartDate ), ...
                                        datenum( obj.globalEndDate ), obj.globalLength ) ;
                                    
             obj.globalDateVec = datevec( globalDatesInts ) ;
             
             obj.globalDates = datestr( obj.globalDateVec, 'yyyy-mm-dd' ) ;
                                                     
            obj.utmx = 0 ;
            obj.utmy = 0 ;
            obj.gridgse = 0 ;
            
        end
         
        function obj = set_values( obj, dataValues ) 
            obj.values = dataValues ;
        end
        
        function obj = set_dates( obj, dataValues ) 
            obj.dates = dataValues ;
        end
      
        function obj = padDataSet( obj )             
   %{
     This function takes an input vector of equal-interval timeseries data,
    and returns a vector for a specific desired time interval, filled in
    with NaNs on either side where they don't overlap
   
    Create and NaN the value vector for the desired length
       Set the timeseries data to within the requested interval
       and replace NaN in the value vector with the data
     
    Must know if dataSet starts first or global dataSet starts first
    then must know of dataSet ends first or global dataSet ends first
    to set up the logig needed to merge the two into the longest possible
    the convention will be if the date difference is positive, it means that
  
     %}
   startDateDiff = ( datenum( obj.startDate ) - datenum( obj.globalStartDate ) ) ;
   endDateDiff   = ( datenum( obj.endDate ) - datenum( obj.globalEndDate ) ) ;
   
   startDateOffset = abs( startDateDiff ) ;
   endDateOffset = abs( endDateDiff ) ;
  
    % initialize the global data set Value Vector 
       obj.globalValues( 1 : obj.globalLength ) = NaN ;
      
   %% Condition 1: global starts first and ends first   
   if startDateDiff >= 0 && endDateDiff > 0
       globalStartIndex = startDateOffset ;
       globalEndIndex   = obj.globalLength ;
       dataSetStartIndex= 1;
       dataSetEndIndex  = obj.length - endDateOffset ;
       
   %% Condition 2: global starts first and ends last   
   
   elseif startDateDiff >= 0 && endDateDiff < 0       
       globalStartIndex = startDateOffset +1 ;
       globalEndIndex   = obj.globalLength - endDateOffset ;
       dataSetStartIndex= 1 ;
       dataSetEndIndex  = obj.length  ;
   
%% Condition 3: global starts last and ends last   
   elseif startDateDiff <= 0 && endDateDiff < 0
       globalStartIndex = 1 ;
       globalEndIndex   = obj.globalLength - endDateOffset ;
       dataSetStartIndex= startDateOffset ;
       dataSetEndIndex  = obj.length ;
                            
    %% Condition 4: global dataSet starts last and ends first
    %% in this case dataSet will be trimed on both ends    
   elseif stardDateDiff <=0  && endDateDiff > 0
       globalStartIndex = 1 ;
       globalEndIndex   = obj.globalLength ;
       dataSetStartIndex= startDateOffset ;
       dataSetEndIndex  = obj.length - endDateOffset ;        
   else
       error('Can''t padd dataSet; Oddly One of the four possible conditions have not been met' )
   end
   
   obj.globalValues( globalStartIndex : globalEndIndex ) = ...
              obj.values( dataSetStartIndex : dataSetEndIndex ) ;

        end
        
        function [ ] = outputDFS0( obj )
%{          
    Create a dfs0 file, set the info and add the valuevector        
%}

% Create the dfs0
dfs0 = dfsTSO( obj.dfs0FileName, 1 ) ;

addTimesteps( dfs0, obj.globalLength ) ;
addItem( dfs0, obj.stationName, obj.dataType, obj.units ) ;
%addItem( dfs0, obj.stationName ) ;
%addItem( dfs0, obj.stationName ) ;
set( dfs0, 'filename', obj.dfs0FileName ) ;
set( dfs0, 'filetitle', obj.title ) ;
%set( dfs0, 'itemcoordinates',[ obj.utmx{:}, obj.utmy{:}, obj.gridgse{:} ] ) ;
set( dfs0, 'itemcoordinates',[ obj.utmx, obj.utmy, obj.gridgse ] ) ;
set( dfs0, 'timeaxistype', 'Equidistant_Calendar' ) ;
set( dfs0, 'startdate', obj.globalStartDate ) ;
set( dfs0, 'timestep', [ 0 0 1 0 0 0 ] ) ;
set(dfs0,'deletevalue', obj.deleteValue ) ;
%set(dfs0,'deletevalue',-1.0e-035);

dfs0(1) = single( obj.globalValues ) ;

% Save and close files
save( dfs0 ) ;
dfs0.Close() ;

end
        
        
    end
end
                
        
       
    
        