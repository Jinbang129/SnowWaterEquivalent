%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is the program for calculating the Snow Water Equivalent from
%FengYun-3 Satelite Images
%Satalite:FY-3A and FY-3B; Sensor: WMRI; Data Level: L1; Orbit:A&D. 
%Author:Jinbang Peng; Coding time: 20171107.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Scan the image files in the appointed fold
FoldPath='C:\FY3\code\datasample\';
% FoldPath='C:\FY3\code\datasample\';
DataPath=dir([FoldPath,'FY3*_MWRI*MS.HDF']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.Data input
for i=1%:numel(DataPath)       
    i=12
    file=[FoldPath,DataPath(i).name];
    hinfo = hdf5info(file); 
%     i=5;
    % Judge the satelite style of the images (FY_3B or FY-3C), cause the
    % data structure is different for FY_3B and FY-3C datasets.
    if strncmp(DataPath(i).name,'FY3B',4)
    %     File_info = h5info(file);
    %     File_name = h5read(file,'/Datasets/EARTH_OBSERVE_BT_10_to_89GHz');
    %     File_name = hdf5read(file,'/File Name');
        Lati_info = hdf5read(hinfo.GroupHierarchy.Datasets(20));%
        Long_info = hdf5read(hinfo.GroupHierarchy.Datasets(21));%
        EO_BT_info = hdf5read(hinfo.GroupHierarchy.Datasets(8));%
    elseif strncmp(DataPath(i).name,'FY3C',4)
        Lati_info = hdf5read(hinfo.GroupHierarchy.Groups(2).Datasets(1));%
        Long_info = hdf5read(hinfo.GroupHierarchy.Groups(2).Datasets(2));%
        EO_BT_info = hdf5read(hinfo.GroupHierarchy.Groups(1).Datasets(2));%
    else
        disp('No FY-3 B&C data available in appointed file fold!');
%         pritf('No file available in appointed file fold!');
%         return;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %2.Atmosphere Correction
    EO_BT_info19h=EO_BT_info(:,:,4);
    EO_BT_info37h=EO_BT_info(:,:,8);
    [EO_BT_Cor1,EO_BT_Cor2]=SWE_AtmCorrection( EO_BT_info19h, EO_BT_info37h);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %3.SWC calculation
    SWC_alg=SWE_Algorithm(EO_BT_Cor1,EO_BT_Cor2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %4.Geo Correction
%     SWE_GeoCor=SWE_GeoCorrection(SWC_alg,Lati_info,Long_info);
     
%     LATLIMS = [60 90];
%     LONLIMS = [-180 180]; 
    
%     m_proj('stereographic','lat',90,'long',0,'radius',60);
%     m_elev('contour',[-3500:1000:-500],'edgecolor','b');
%     m_grid('xtick',12,'tickdir','out','ytick',[ 40  60  80],'linest','-');
%     m_coast('patch',[.7 .7 .7],'edgecolor','r');
    
%     [x,y] = projfwd('stereographic',Long_info,Lati_info);
    
%     m_proj('stereographic','lat',90,'long',30,'radius',25);
%     m_coord('geographic');           % Define all in geographic
    indata = double(SWC_alg); 
    lat = double(Lati_info);
    lon = double(Long_info);
    mstruct = defaultm('stereo');
%     [x,y] = projfwd(mstruct,Lati_info,Long_info);
    axesm ('stereo', 'Frame', 'on', 'Grid', 'on','Origin', [90 60 60]);
    surfm( lat, lon, indata)
%     pcolorm(y, x, indata);
%     landareas = shaperead('landareas.shp','UseGeoCoords',true);
%     geoshow(landareas,'FaceColor',[1 1 1],'EdgeColor',[.4 .4 .4]);
    load coastlines;
    plotm(coastlat,coastlon,'lineColor',[.1 .1 .1]);
    h=colorbar;
    set(get(h,'ylabel'),'String','SWE (mm)');
%     tissot;


%     colormap(jet);
%     hold on;
%     EO_BT_info1=double(SWC_alg);
%     m_pcolor(X,Y,SWC_alg);
%     
%     % lon/lat of grid corners
%     Lati_maxi = ceil(max(max(Lati_info)));Lati_mini = floor(min(min(Lati_info)));%%
%     Long_maxi = ceil(max(max(Long_info)));Long_mini = floor(min(min(Long_info)));%%
% 
%     Lati_step = (Lati_maxi-Lati_mini)/size(Lati_info,2);%
%     Long_step = (Long_maxi-Long_mini)/size(Long_info,1);%
% 
%     lon = Long_mini+Long_step*0.5:Long_step:Lati_maxi-Long_step*0.5;
%     lat = Lati_mini+Lati_step*0.5:Lati_step:Lati_maxi-Lati_step*0.5;
% 
%     [Plg,Plt]=meshgrid(lat,lon);
%     
%     
%     % Get the indices needed for the area of interest
%     [mn,ilt]=min(abs(lat-max(LATLIMS)));
%     [mn,ilg]=min(abs(lon-min(LONLIMS)));
%     ltlm=fix(diff(LATLIMS)/Lati_step);
%     lglm=fix(diff(LONLIMS)/Long_step);
%  
%     
%     
%     % load the subset of data needed for the map limits given
% 
%     % Convert data into log(Chla) using the equations given. Blank no-data.
%     % P=double(P);
%     % P(P==65535)=NaN;
%     % P=(pin.Slope*P+pin.Intercept);   % log_10 of chla
%     indata = double(SWC_alg);
%  
%     LT=lat(ilt+[0:ltlm-1]);LG=lon(ilg+[0:lglm-1]);
%     [Plg,Plt]=meshgrid(LG,LT);
%     colormap(jet);
%     % Draw the map...    m_grid('xtick',12,'tickdir','out','ytick',[70 80],'linest','-');
%    
%     m_coast('patch',[.7 .7 .7],'edgecolor',[.2 .2 .2]);
%     m_grid('linewi',2,'tickdir','out','backcolor',[.9 .99 1]);
%     hold on;
%     m_pcolor(Plg,Plt,indata);
%     shading flat;
%     h=colorbar;
%     set(get(h,'ylabel'),'String','Normalized Difference Vegetation Index');
%     title(['SeaWIFS NDVI   ' ],...
%           'fontsize',14,'fontweight','bold');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %6.Daily SWE
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %7.Data output
    
%     OutputFoldPath='.\Output\';
%     OutputPath=[OutputFoldPath,DataPath(i).name(1:end-4),'.tiff'];
%     
%     LATLIMS = [25 90];
%     LONLIMS = [-180 180];    
% 
%     Lati_maxi = ceil(max(max(Lati_info)));Lati_mini = floor(min(min(Lati_info)));%%
%     Long_maxi = ceil(max(max(Long_info)));Long_mini = floor(min(min(Long_info)));%%
% 
%     Lati_step = (Lati_maxi-Lati_mini)/size(Lati_info,2);%
%     Long_step = (Long_maxi-Long_mini)/size(Long_info,1);%
% 
%     lon_mesh = Long_mini:Long_step:Lati_maxi;
%     lat_mesh = Lati_mini:Lati_step:Lati_maxi;
% 
%     [lon,lat] = meshgrid(lat_mesh, lon_mesh);
%      
%     indata = double(SWC_alg);
%     x = double(lon);
%     y = double(lat);
% 
% 
%     maxiu  =  max(max(indata));
%     miniu  =  min(min(indata));
% 
%     % clf  
%     figure;
%     axis off
% 
%     axesm ('lambert', 'Frame', 'on', 'Grid', 'on','GLineStyle','--', 'LabelFormat','compass','MapLatLimit',LATLIMS,'Maplonlimit',LONLIMS,'ParallelLabel','on','MeridianLabel','on','FontWeight','bold');
%     setm(gca,'MLabelLocation',5);
%     setm(gca,'MLineLocation',5);
%     setm(gca,'PLabelLocation',5);
%     setm(gca,'PLineLocation',5);
% 
%     % landareas = shaperead('landareas.shp','UseGeoCoords',true);
%     % axesm ('lambert', 'Frame', 'on', 'Grid', 'on');
%     % geoshow(landareas,'FaceColor',[1 1 .5],'EdgeColor',[.6 .6 .6]);
%     % tissot;
% 
%     pcolorm(y, x, indata);
%     caxis([miniu maxiu]);
%     cmap = colormap(jet);
%     colormap(cmap);
% 
%     c = colorbar( 'eastoutside' );
%     c.Label.String = 'SWE (mm)';
% 
%     load coast
%     plotm(lat, long, 'k')    
%     % landareas = shaperead('landareas.shp','UseGeoCoords',true);
%     % geoshow(landareas,'FaceColor',[1 1 .5],'EdgeColor',[.6 .6 .6]);
%     % S = shaperead('landareas','UseGeoCoords',true);
%     % geoshow([S.Lat], [S.Lon],'Color','black');
%     title(['SWE over Northern hemisphere' ],...
%           'fontsize',14,'fontweight','bold');
% 
% 
% 
%     %     SWE_GeoCo_1=-SWE_GeoCor;
%     %     imwrite( SWE_GeoCo_1,OutputPath,'tiff' );
%     %     t = Tiff(OutputPath,'w');
%     %     t.write(SWE_GeoCor);
%         %geotiffwrite(OutputPath,SWE_GeoCor,R);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%  imshow(SWE_GeoCor);