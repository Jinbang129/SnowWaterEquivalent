% Ocean colour data from http://seawifs.gsfc.nasa.gov/SEAWIFS.html
%
% Take a 4km weakly average dataset and plot a map for the Strait of
% Georgia and outer coast. Note that most of this code is used
% for reading in and subsetting the data.

 LATLIMS = [25 90];
 LONLIMS = [-180 180];

% Note - This is probably not the most efficient way to read and
%        handle HDF data, but I don't usually do this...
%
% First, get the attribute data
FoldPath='C:\FY3\code\datasample\';
% FoldPath='C:\FY3\code\datasample\';
DataPath=dir([FoldPath,'FY3B*_MWRI*MS.HDF']);
file=[FoldPath,DataPath(1).name];
PI = hdf5info(file); 

Lati_info = hdf5read(PI.GroupHierarchy.Datasets(20));%
Long_info = hdf5read(PI.GroupHierarchy.Datasets(21));%
EO_BT_info = hdf5read(PI.GroupHierarchy.Datasets(8));%

%PI=hdfinfo('A20040972004104.L3m_8D_CHLO_4KM');
% And write it into a structure
% pin=[];
% for k=1:69,
%   nm=PI.GroupHierarchy.Attributes(k).Name;nm(nm==' ')='_';
%   if isstr(PI.GroupHierarchy.Attributes(k).Value),
%     pin=setfield(pin,nm,PI.GroupHierarchy.Attributes(k).Value);
%   else
%     pin=setfield(pin,nm,double(PI.GroupHierarchy.Attributes(k).Value));
%   end
% end; 

% lon/lat of grid corners
% lon=[pin.Westernmost_Longitude:pin.Longitude_Step:pin.Easternmost_Longitude];
% lat=[pin.Northernmost_Latitude:-pin.Latitude_Step:pin.Southernmost_Latitude];
 
    Lati_maxi = ceil(max(max(Lati_info)));Lati_mini = floor(min(min(Lati_info)));%%
    Long_maxi = ceil(max(max(Long_info)));Long_mini = floor(min(min(Long_info)));%%

    Lati_step = (Lati_maxi-Lati_mini)/size(Lati_info,2);%
    Long_step = (Long_maxi-Long_mini)/size(Long_info,1);%

    lon = Long_mini:Long_step:Lati_maxi;
    lat = Lati_mini:Lati_step:Lati_maxi;
    
    
% Get the indices needed for the area of interest
[mn,ilt]=min(abs(lat-max(LATLIMS)));
[mn,ilg]=min(abs(lon-min(LONLIMS)));
ltlm=fix(diff(LATLIMS)/Lati_step);
lglm=fix(diff(LONLIMS)/Long_step);

% load the subset of data needed for the map limits given
PI = hdf5info(file,'l3m_data','Index',{[ilt ilg],[],[ltlm lglm]});

% Convert data into log(Chla) using the equations given. Blank no-data.
P=double(P);
P(P==255)=NaN;
P=(pin.Slope*P+pin.Intercept);   % log_10 of chla

LT=lat(ilt+[0:ltlm-1]);LG=lon(ilg+[0:lglm-1]);
[Plg,Plt]=meshgrid(LG,LT);

% Draw the map...

clf;
m_proj('lambert','lon',LONLIMS,'lat',LATLIMS);
m_pcolor(Plg,Plt,P);shading flat;
m_gshhs_i('color','k');;
m_grid('linewi',2,'tickdir','out');;
h=colorbar;
set(get(h,'ylabel'),'String','Chla (\mug/l)');
set(h,'ytick',log10([.5 1 2 3 5 10 20 30]),'yticklabel',[.5 1 2 3 5 10 20 30],'tickdir','out');
title(['MODIS Chla   ' datestr(datenum(pin.Period_Start_Year,1,0)+pin.Period_Start_Day) ' -> ' ...
                       datestr(datenum(pin.Period_Start_Year,1,0)+pin.Period_End_Day)],...
       'fontsize',14,'fontweight','bold');
