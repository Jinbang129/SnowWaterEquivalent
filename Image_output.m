%Image output
function t=Image_output(i,SWC_alg,Lati_info,Long_info,fn_output)                    
                    
indata = double(SWC_alg);
lat = double(Lati_info);
lon = double(Long_info);

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
                    
[Xq,Yq] = meshgrid(-1.42:0.001:1.42,-1.42:0.001:1.42);
sum(sum(isnan(indata)));

                    % Wrap the image with NaN to avoid the number spill
                    % over frin the image
%                      x1 = zeros(size(x,1)+2,size(x,2)+2)*nan;
%                      y1 = zeros(size(y,1)+2,size(y,2)+2)*nan;
%                      indata = zeros(size(indata,1)+2,size(indata,2)+2)*nan;
%                      x1(2:end-1,2:end-1)=x;
%                      y1(2:end-1,2:end-1)=y;
                    
SWE_Grid = round(griddata(x,y,indata,Xq,Yq,'cubic'));
%                     SWE_Grid (isnan(SWE_Grid)) = 255;
%                     SWE_Grid (SWE_Grid<0) = 0;
%                     imwrite(int16(SWE_Grid),fn_output,'Tiff');


                    