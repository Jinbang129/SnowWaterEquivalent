%**************************************************************************
%This is the program for calculating the Snow Water Equivalent from
%FengYun-3 Satelite Images
%Satalite:FY-3A and FY-3B; Sensor: WMRI; Data Level: L1; Orbit:A&D. 
%Author:Jinbang Peng; Coding time: 20171107.
%**************************************************************************


%Scan the image files in the appointed fold
FoldPath='C:\FY3\code\datasample\new\';
% FoldPath='C:\FY3\code\datasample\';
for yyyy = 2010:2017
    for mm = 1:12
        for dd = 1:31
               
            FY_lst=['FY3*_MWRI*',num2str(yyyy,'%02d'),num2str(mm,'%02d'),num2str(dd,'%02d'),'*MS.HDF'];
            DataPath=dir([FoldPath,FY_lst]);
            Num_image=numel(DataPath);
            if Num_image==0
                fprintf(['No image for the day:',num2str(yyyy,'%02d'),num2str(mm,'%02d'),num2str(dd,'%02d'),'\n']);
            else
                Map_name=['SWE',num2str(yyyy,'%02d'),num2str(mm,'%02d'),num2str(dd,'%02d')];
                f=figure('Name',Map_name,'visible','on','position',[0 0 4000 4000],'outerposition',[0 0 4000 4000]);
                gca=axesm ('eqaazim', 'Frame','on','Grid','on','FLineWidth',1 ,...
                    'Origin',[90 90 0],'MapLatLimit',[0 90],'MeridianLabel','on',...
                    'ParallelLabel','on','MLabelParallel','south');

            %--------------------------------------------------------------
            %1.Data input
                for i=1:Num_image
%                     i
                    file  = [FoldPath,DataPath(i).name];
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
                    end
                %--------------------------------------------------------------


                %--------------------------------------------------------------
                    %2.Atmosphere Correction
                    EO_BT_info1=EO_BT_info(:,:,4);
                    EO_BT_info2=EO_BT_info(:,:,8);
                    [EO_BT_Cor1,EO_BT_Cor2]=SWE_AtmCorrection( EO_BT_info1, EO_BT_info2);
                %--------------------------------------------------------------


                %--------------------------------------------------------------
                    %3.SWC calculation
                    SWC_alg=SWE_Algorithm(EO_BT_Cor1,EO_BT_Cor2);
                %--------------------------------------------------------------

                %--------------------------------------------------------------
                    %4.Map display and output
                    indata = double(SWC_alg);
                    lat = double(Lati_info);
                    lon = double(Long_info);
                    %gca=figure('visible','off');

                    surfm(lat, lon, indata);
                    fn_output_title=['Snow Water Equivalent over Subarctic Area in ',...
                        num2str(yyyy),num2str(mm,'%02d'),num2str(dd,'%02d')];
                    title(fn_output_title,'FontSize',14,'FontWeight','Bold');
                %     pcolorm(y, x, indata);
                %     landareas = shaperead('landareas.shp','UseGeoCoords',true);
                %     geoshow(landareas,'FaceColor',[1 1 1],'EdgeColor',[.4 .4 .4]);
                    load coastlines;
                    plotm(coastlat,coastlon,'black');
%                   tissot;
                    h=colorbar;
                    set(get(h,'ylabel'),'String','Snow Water Equivalent(mm)');

    %                 scrsz = get(0,'ScreenSize');
    %                 set(f,'position',scrsz,'PaperPositionMode','auto');
                %--------------------------------------------------------------

                %--------------------------------------------------------------
                    %5.Image output
                    mstruct = defaultm('eqaazim');  % Lambert Azimuthal Equal-Area Projection
                    mstruct.origin = [90 90 0];     %Set North Pole Point as the origin
                    mstruct.maplatlimit = [20 90];
                    mstruct = defaultm(mstruct);
    %                 lat(lat<0)=0;
    %                 lon(lat==0)=0;
    %                 [x1,y1] = mfwdtran(mstruct,lat,lon);
                    [x,y] = projfwd(mstruct,lat,lon);
                    for grid_row=1:size(x,1)
                        for grid_col=1:size(x,2)
                            if (x(grid_row,grid_col)^2+y(grid_row,grid_col)^2)>2
                                indata(grid_row,grid_col)=NaN;
                            end
                        end
                    end
                    for grid_row=1:size(x,1)
                        for grid_col=1:size(x,2)
                            if isnan(x(grid_row,grid_col))||isnan(y(grid_row,grid_col))
                                x(grid_row,grid_col)=0;
                                y(grid_row,grid_col)=0;
                                indata(grid_row,grid_col)=NaN;
                            end
                        end
                    end
                    
                    [Xq,Yq] = meshgrid(-2:0.002:2,-2:0.002:2);
                    sum(sum(isnan(indata)));

                    SWE_Grid = round(griddata(x,y,indata,Xq,Yq,'nearest'));

                    fn_output=[num2str(yyyy),num2str(mm,'%02d'),num2str(dd,'%02d'),'_',num2str(i,'%02d'),'.tif'];
                    imwrite(SWE_Grid,fn_output,'tif');

                end
                fn_output_map=[num2str(yyyy,'%02d'),num2str(mm,'%02d'),num2str(dd,'%02d'),'_map','.tif'];
                saveas(f,fn_output_map);
                %--------------------------------------------------------------
            end
        end
    end
end