%% Read shoreline and border data 
shorelines=gshhs('F:\landmask\gshhs_i.b',[0 90],[-180 180]);
% borders=gshhs('F:\landmask\wdb_borders_i.b',[10 65],[100 138]);
%% Read station information (name,lat,lon,...)
% fid=fopen('F:\landmask\dENU_JapanAround.dat');
% stainfo=textscan(fid,'%s%f%f%f%f%f%f%f%f%f%f%f'); fclose(fid);
%% Plot map
figure('position',[50 50 800 600]);
axesm('eqaazim', 'Frame','on','Grid','on','FLineWidth',1 ,...
                            'Origin',[90 90 0],'MapLatLimit',[0 90],'MeridianLabel','off',...
                            'ParallelLabel','off','MLabelParallel','south');
%Shorelines and borders
levels=[shorelines.Level];
LevelString=[shorelines.LevelString];
land=(levels==1);
sea=(levels~=land);
geoshow(shorelines(sea),'facecolor',[0.8 1 1]);
% geoshow(borders);