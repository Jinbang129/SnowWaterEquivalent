FoldPath='C:\FY3\201706SWE\_\';
% FoldPath='C:\FY3\code\datasample\';
DataPath = dir([FoldPath,'FY3*_MWRI*MS.HDF']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.Data input
for i=1:numel(DataPath)
%     i=5;
    file=[FoldPath,DataPath(i).name];
    i
    hinfo = hdf5info(file); 
    EO_BT_info1 = hdf5read(hinfo.GroupHierarchy.Datasets(9));
    EO_BT_info2 = hdf5read(hinfo.GroupHierarchy.Datasets(13));
end