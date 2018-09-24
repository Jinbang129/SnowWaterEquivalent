% Image output
function SWE_proj_max=Image_projection_new(indata,lat,lon,SWE_proj_max)

mstruct = defaultm('eqaazim');  % Lambert Azimuthal Equal-Area Projection
mstruct.origin = [90 90 0];     %Set North Pole Point as the origin
mstruct.maplatlimit = [0 90];
mstruct = defaultm(mstruct);

[x,y] = projfwd(mstruct,lat,lon);
[X,Y] = projfwd(mstruct,[0 0 0 0],[0 90 180 -90]);
x=1000*x;
y=1000*y;
X=round(1000*X);
Y=round(1000*Y);
% 
% for row=1:size(x,1)
%     for col=1:size(x,2)
%         if (x(row,col)^2+y(row,col)^2)>2000000
%             x(row,col)=NaN;
%         end
%     end
% end

SWE_proj= zeros(2841,2841)*NaN;
for row=1:size(x,1)
    for col=1:size(x,2)
        if ~isnan(x(row,col))&&~isnan(y(row,col))&&((x(row,col)^2+y(row,col)^2)<=2000000)
            x(row,col)=round(x(row,col));
            y(row,col)=round(y(row,col));
%             SWE_proj(x(row,col)+1420,y(row,col)+1420)=nanmean([SWE_proj(x(row,col)+1420,y(row,col)+1420),indata(row,col)]);
        end
    end
end

% [Xq,Yq] = meshgrid(-1414:1:1414,-1414:1:1414);
[Xq,Yq] = meshgrid(-1420:1:1420,-1420:1:1420);
SWE_proj=interp2(x,y,indata,Xq,Yq,'cubic',NaN);


% 
% 
% 
% 

% 
% % Peocess the grids where latitude or longitude is NaN
% for row=1:size(x,1)
%     for col=1:size(x,2)
%         
%         if isnan(x(row,col))
%             if col>1
%                 x(row,col)=x(row,col-1);
%             else
%                 x(row,col)=x(row-1,col)+1;
%                 % 0.001 is the distance of meshgrid stated below
%             end
%         end
%         
%         if isnan(y(row,col))
%             if row>1
%                 y(row,col)=y(row-1,col);
%             else
%                 y(row,col)=y(row,col-1)+1;
%             end
%         end
%         
%     end
% end
% 
% [Xq,Yq] = meshgrid(-1420:1:1420,-1420:1:1420);
% % sum(sum(isnan(indata)));
% 
% SWE_proj = round(griddata(x,y,indata,Xq,Yq,'cubic'));
% % 
% % F = scatteredInterpolant(x,y,indata);
% % SWE_proj = F(Xq,Yq);
% 
% % Vq = interp2(x,y,indata,Xq,Yq);
% % 
[column,row] = geo2easeGrid_jinbang(lat,lon);
[col_lim,row_lim] = geo2easeGrid_jinbang([0 0 0 0],[0 90 180 -90]);
% 
% [column,row] = geo2easeGrid(lat,lon);
% [col_lim,row_lim] = geo2easeGrid([0 0 0 0],[0 90 180 -90]);
% colmax=max(col_lim);colmin=min(col_lim);
% rowmax=max(row_lim);rowmin=min(row_lim);
% SWE_proj= zeros(colmax-colmin+1,rowmax-rowmin+1)*NaN;


% SWE_proj(SWE_proj<0) = 0;
SWE_proj_max = nanmax(SWE_proj_max,SWE_proj);


