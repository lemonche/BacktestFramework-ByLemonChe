function [Output,filename] = generateCatalog(RootCatalog)
filename = datestr(now, 'yyyy-mm-dd_hhMMssFFF');
Output = [RootCatalog,filename, '\'];
mkdir(Output)
