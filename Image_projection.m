% Image output
function SWE_proj_max=Image_projection(indata,lat,lon,SWE_proj_max)

mstruct = defaultm('eqaazim');  % Lambert Azimuthal Equal-Area Projection
mstruct.origin = [90 90 0];     %Set North Pole Point as the origin
mstruct.maplatlimit = [0 90];
mstruct = defaultm(mstruct);

[x,y] = projfwd(mstruct,lat,lon);
x=1000*x;
y=1000*y;

for grid_row=1:size(x,1)
    for grid_col=1:size(x,2)
        if (x(grid_row,grid_col)^2+y(grid_row,grid_col)^2)>2000000
            indata(grid_row,grid_col)=NaN;
        end
    end
end

% Peocess the grids where latitude or longitude is NaN
for grid_row=1:size(x,1)
    for grid_col=1:size(x,2)
        
        if isnan(x(grid_row,grid_col))
            if grid_col>1
                x(grid_row,grid_col)=x(grid_row,grid_col-1);
            else
                x(grid_row,grid_col)=x(grid_row-1,grid_col)+1;
                % 0.001 is the distance of meshgrid stated below
            end
        end
        
        if isnan(y(grid_row,grid_col))
            if grid_row>1
                y(grid_row,grid_col)=y(grid_row-1,grid_col);
            else
                y(grid_row,grid_col)=y(grid_row,grid_col-1)+1;
            end
        end
        
    end
end

[Xq,Yq] = meshgrid(-1420:1:1420,-1420:1:1420);
% sum(sum(isnan(indata)));

SWE_proj = round(griddata(x,y,indata,Xq,Yq,'cubic'));
    % 
    % F = scatteredInterpolant(x,y,indata);
    % SWE_proj = F(Xq,Yq);

    % Vq = interp2(x,y,indata,Xq,Yq);
    % 
    % [column,row] = geo2easeGrid_jinbang(lat,lon);
    % [col_lim,row_lim] = geo2easeGrid_jinbang([0 0 0 0],[0 90 180 -90]);

% [column,row] = geo2easeGrid(lat,lon);
% [col_lim,row_lim] = geo2easeGrid([0 0 0 0],[0 90 180 -90]);
% colmax=max(col_lim);colmin=min(col_lim);
% rowmax=max(row_lim);rowmin=min(row_lim);
% SWE_proj= zeros(colmax-colmin+1,rowmax-rowmin+1)*NaN;

SWE_proj(SWE_proj<0) = 0;
SWE_proj_max = nanmax(SWE_proj_max,SWE_proj);


