 function status = loadDotNet( matDir )
        %load .NET DHI dfs libraries
        %the mbin directory is also from DHI
%apparenty this contians the DfsTSO class and the DFS class
%and the MatlabDfsUtil.2016.dll

path( path,[ matDir 'mbin' ] );

%load the .NET .dll  (aka an Assembly)
%these are located in C:\Windows\Microsoft.NET\assembly\GAC_MSIL
%and were part of the MikeZero install
%not sure which ones are actually required.

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');

%load modules (I guess that is what they are called) from the .dll
%at this point I am not sure which ones are precisely required.

import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

status = 1 ;
        end
       