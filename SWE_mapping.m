%**************************************************************************
%This is the program for calculating the Snow Water Equivalent from
%FengYun-3 Satelite Images
%Satalite:FY-3A or FY-3B; Sensor: WMRI; Data Level: L1; Orbit:A&D.
%Author:Jinbang Peng.
%Coding time: 20171107.
%**************************************************************************
clc
clear all;

%Scan the image files in the appointed fold
FoldPath='F:\FY3_ABC_MWRI_L1Data\201702\_\';
Fold_output_path='F:\FY3_ABC_MWRI_L1Data\output\';
for yyyy = 2010:2017
    for mm = 1:12
        for dd = 1:31
            orbit=['A','D'];
            satllt=['B','C'];
            for orbt_indx = 1:2
                for sat_index=1:2
                    
                    FY_lst=['FY3',satllt(sat_index),'_MWRI',orbit(orbt_indx),'*',num2str(yyyy,'%02d'),...
                        num2str(mm,'%02d'),num2str(dd,'%02d'),'*MS.HDF'];
                    DataPath=dir([FoldPath,FY_lst]);
                    Num_image=numel(DataPath);
                    
                    if Num_image==0
                        fprintf(['No image for ',num2str(yyyy,'%02d'),num2str(mm,'%02d'),num2str(dd,'%02d'),'\n']);
                    else
                        Map_name=['SWE','_',satllt(sat_index),'_',orbit(orbt_indx),'_',num2str(yyyy,'%02d'),...
                            num2str(mm,'%02d'),num2str(dd,'%02d')];
                        f=figure('Name',Map_name,'visible','off','position',[0 0 4000 4000],'outerposition',[0 0 4000 4000]);
                        gca=axesm ('eqaazim', 'Frame','on','Grid','on','FLineWidth',1 ,...
                            'Origin',[90 90 0],'MapLatLimit',[60 90],'MeridianLabel','on',...
                            'ParallelLabel','on','MLabelParallel','south');
                        

%                         SWE_proj = zeros(2841,2841)*NaN;    %state array for hold the image data after projection
%                         SWE_proj_max = zeros(2841,2841)*NaN;%hold the maximum image data over overlayed area after projection
%                         NaN_index = zeros(2841,2841);       %counter for record NaN for every grid when integrate all images for one day
                        
                        %--------------------------------------------------------------
                        %Data input
                        for i=1:Num_image
                            i
                            file  = [FoldPath,DataPath(i).name];
                            hinfo = hdf5info(file);
                            
                            % Judge the satelite style of the images (FY_3B or FY-3C), cause the
                            % data structure is different for FY_3B and FY-3C datasets.
                            if sat_index==1
                                
                                EO_BT_info = hdf5read(hinfo.GroupHierarchy.Datasets(8));%
                                Lati_info = hdf5read(hinfo.GroupHierarchy.Datasets(20));%
                                Long_info = hdf5read(hinfo.GroupHierarchy.Datasets(21));%
                                LandCover = hdf5read(hinfo.GroupHierarchy.Datasets(18));%
                                LandSeaMask = hdf5read(hinfo.GroupHierarchy.Datasets(19));%
                                
                            elseif sat_index==2
                                
                                EO_BT_info = hdf5read(hinfo.GroupHierarchy.Groups(1).Datasets(2));%
                                Lati_info = hdf5read(hinfo.GroupHierarchy.Groups(2).Datasets(1));%
                                Long_info = hdf5read(hinfo.GroupHierarchy.Groups(2).Datasets(2));%
                                
                                LandCover = hdf5read(hinfo.GroupHierarchy.Groups(1).Datasets(3));%
                                %0 Water 1 Evergreen Needleleaf Forest 2 Evergreen Broadleaf Forest
                                %3 Deciduous Needleleaf Forest 4 Deciduous Broadleaf Forest
                                %5 Mixed Forests 6 Closed Shrublands 7 Open Shrublands
                                %8 Woody Savannas 9 Savannas 10 Grasslands 11 Permanent Wetlands
                                %12 Croplands 13 Urban and Built-Up 14 Cropland/Natural Vegetation Mosaic
                                %15 Snow and Ice 16 Barren or Sparsely Vegetated
                                %17(IGBP Water Bodies, recoded to 0 for MODIS Land Product consistency.)
                                %254 Unclassified  255 Fill Value
                                
                                LandSeaMask = hdf5read(hinfo.GroupHierarchy.Groups(1).Datasets(4));
                                % land sea mask, with 1=land£¬ 2=land water£¬ 3=sea£¬ 5=boundry   
                            end
                            %--------------------------------------------------------------
                            
                            %--------------------------------------------------------------
                            % Exlcude the regein of sea
%                             shorelines=gshhs('F:\landmask\gshhs_i.b',[0 90],[-180 180]);
%                             levels=[shorelines.Level];
%                             land=(levels==1);
                             
                            LandSeaMask(LandSeaMask~=1)=NaN;
%                             EO_BT_info(LandSeaMask~=1)=NaN;
%                             EO_BT_info(LandSeaMask==2)=NaN; %land water
%                             EO_BT_info(LandSeaMask==3)=NaN; %sea
%                             EO_BT_info(LandSeaMask==5)=NaN; %boundry
%                             EO_BT_info(LandCover==0)=NaN;   %water
                            %--------------------------------------------------------------
                            
                            %--------------------------------------------------------------
                            % Atmosphere Correction
                            EO_BT_info10=EO_BT_info(:,:,4);
                            EO_BT_info19H=EO_BT_info(:,:,4);
                            EO_BT_info37H=EO_BT_info(:,:,8);
                            [EO_BT_Cor19H,EO_BT_Cor37H] = SWE_AtmCorrection( EO_BT_info19H, EO_BT_info37H);
                            %--------------------------------------------------------------
                            
                            %--------------------------------------------------------------
                            % SWC calculation
                            SWC_alg=SWE_Algorithm(EO_BT_Cor19H,EO_BT_Cor37H);
                            %--------------------------------------------------------------
                            
                            %--------------------------------------------------------------
                            indata = double(SWC_alg);
                            lat = double(Lati_info);
                            lon = double(Long_info);
                            indata(LandSeaMask==0)=0;
                            indata(isnan(LandSeaMask))=NaN;
                            
                            %4.Map display and output
                            surfm(lat, lon, indata);
                            fn_output_title=['Snow Water Equivalent over Subarctic Area in ',...
                                num2str(yyyy),num2str(mm,'%02d'),num2str(dd,'%02d'),' from FY-3',...
                                satllt(sat_index),' Orbit ',orbit(orbt_indx)];
                            title([fn_output_title],'FontSize',14,'FontWeight','Bold');
                            %pcolorm(y, x, indata);
                            %landareas = shaperead('landareas.shp','UseGeoCoords',true);
                            %geoshow(landareas,'FaceColor',[1 1 1],'EdgeColor',[.4 .4 .4]);
                            load coastlines;
                            plotm(coastlat,coastlon,'black');
                            %tissot;
                            h=colorbar;
                            set(get(h,'ylabel'),'String','Snow Water Equivalent(mm)');
                            %--------------------------------------------------------------

                        end
                        
                        % Map output
                        fn_output_map=[Fold_output_path,num2str(yyyy,'%02d'),num2str(mm,'%02d'),...
                            num2str(dd,'%02d'),'_',satllt(sat_index),'_',orbit(orbt_indx),'_','map','.tif'];
                        saveas(f,fn_output_map);
                        
                        % Variables release
                        clearvars -except FoldPath Fold_output_path yyyy mm dd...
                            orbit satllt orbt_indx sat_index FY_lst DataPath Num_image;
                        clear SWE_AtmCorrection SWE_Algorithm clear Image_projection;
                        %--------------------------------------------------------------
                    end
                end
            end
        end
    end
end