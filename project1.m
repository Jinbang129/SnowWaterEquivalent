LATLIMS=[40 60];
LONLIMS=[-130 -100];
m_proj('Lambert Conformal Conic','lon',LONLIMS,'lat',LATLIMS','radius',65);
% Note - This is probably not the most efficient way to read and
%        handle HDF data, but I don't usually do this...
%
% First, get the attribute data
PI=hdfinfo('S20090652009072.L3m_8D_LAND_NDVI_4km');
% And write it into a structure
pin=[];
for k=1:59,
 nm=PI.Attributes(k).Name;nm(nm==' ')='_';
 if isstr(PI.Attributes(k).Value),
   pin=setfield(pin,nm,PI.Attributes(k).Value);
 else
   pin=setfield(pin,nm,double(PI.Attributes(k).Value));
 end
end;  
 
% lon/lat of grid corners
lon=[pin.Westernmost_Longitude:pin.Longitude_Step:pin.Easternmost_Longitude];
lat=[pin.Northernmost_Latitude:-pin.Latitude_Step:pin.Southernmost_Latitude];
 
% Get the indices needed for the area of interest
[mn,ilt]=min(abs(lat-max(LATLIMS)));
[mn,ilg]=min(abs(lon-min(LONLIMS)));
ltlm=fix(diff(LATLIMS)/pin.Latitude_Step);
lglm=fix(diff(LONLIMS)/pin.Longitude_Step);
 
% load the subset of data needed for the map limits given
P=hdfread('S20090652009072.L3m_8D_LAND_NDVI_4km','l3m_data','Index',{[ilt ilg],[],[ltlm lglm]});
 
% Convert data into log(Chla) using the equations given. Blank no-data.
P=double(P);
P(P==65535)=NaN;
P=(pin.Slope*P+pin.Intercept);   % log_10 of chla
 
LT=lat(ilt+[0:ltlm-1]);LG=lon(ilg+[0:lglm-1]);
[Plg,Plt]=meshgrid(LG,LT);
colormap(jet);
% Draw the map...
m_coast;
m_grid('linewi',2,'tickdir','out','backcolor',[.9 .99 1]);
hold on;
m_pcolor(Plg,Plt,P);
shading flat;
h=colorbar;
set(get(h,'ylabel'),'String','Normalized Difference Vegetation Index');
title(['SeaWIFS NDVI   ' ],...
      'fontsize',14,'fontweight','bold');
end