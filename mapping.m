LATLIMS=[40 90];
LONLIMS=[0 180];
% Note - This is probably not the most efficient way to read and
%        handle HDF data, but I don't usually do this...
%
% First, get the attribute data
FoldPath='C:\FY3\code\datasample\';
% FoldPath='C:\FY3\code\datasample\';
DataPath = dir([FoldPath,'FY3*_MWRI*MS.HDF']);
file=[FoldPath,DataPath(1).name];
    
PI=hdf5info(file);
% And write it into a structure
pin=[];
for k=1:69,
 nm=PI.GroupHierarchy.Attributes(k).Name;nm(nm==' ')='_';
 if isstr(PI.GroupHierarchy.Attributes(k).Value),
   pin=setfield(pin,nm,PI.GroupHierarchy.Attributes(k).Value);
 else
   pin=setfield(pin,nm,double(PI.GroupHierarchy.Attributes(k).Value));
 end
end;  

lon=[pin.Westernmost_Longitude:pin.Longitude_Step:pin.Easternmost_Longitude];
lat=[pin.Northernmost_Latitude:-pin.Latitude_Step:pin.Southernmost_Latitude];

% lon/lat of grid corners
lon=[pin.Westernmost_Longitude:pin.Longitude_Step:pin.Easternmost_Longitude];
lat=[pin.Northernmost_Latitude:-pin.Latitude_Step:pin.Southernmost_Latitude];
 
% Get the indices needed for the area of interest
[mn,ilt]=min(abs(lat-max(LATLIMS)));
[mn,ilg]=min(abs(lon-min(LONLIMS)));
ltlm=fix(diff(LATLIMS)/pin.Latitude_Step);
lglm=fix(diff(LONLIMS)/pin.Longitude_Step);
 
% load the subset of data needed for the map limits given
EO_BT_info = hdf5read(hinfo.GroupHierarchy.Datasets(8));
P=EO_BT_info(:,:,4);
 

P=double(P);
P(P==65535)=NaN;
P=(pin.Slope*P+pin.Intercept);  
 
LT=lat(ilt+[0:ltlm-1]);LG=lon(ilg+[0:lglm-1]);
[Plg,Plt]=meshgrid(LG,LT);
 
indata = double(P);
x=double(Plg);
y=double(Plt);

   
maxiu  =  max(max(indata));
miniu   =  min(min(indata));
 
% clf  
figure;
axis off
 
axesm ('lambert', 'Frame', 'on', 'Grid', 'on','GLineStyle','--', 'LabelFormat','compass','MapLatLimit',LATLIMS,'Maplonlimit',LONLIMS,'ParallelLabel','on','MeridianLabel','on','FontWeight','bold');
setm(gca,'MLabelLocation',5);
setm(gca,'MLineLocation',5);
setm(gca,'PLabelLocation',5)
setm(gca,'PLineLocation',5);
 
 
pcolorm(y, x, indata);
caxis([miniu maxiu]);
cmap = colormap(jet);
colormap(cmap);

c = colorbar( 'eastoutside' );
c.Label.String = 'P(degree)';

load coast
plotm(lat, long, 'k')    
% landareas = shaperead('landareas.shp','UseGeoCoords',true);
% geoshow(landareas,'FaceColor',[1 1 .5],'EdgeColor',[.6 .6 .6]);
% S = shaperead('landareas','UseGeoCoords',true);
% geoshow([S.Lat], [S.Lon],'Color','black');
title(['SeaWIFS NDVI   ' ],...
      'fontsize',14,'fontweight','bold');
% end