%% This is the function for realizing the algorithm of SWE retrival.
% 
%  PREFORMATTED
%  TEXT
% 
% 
% 
%   for x = 1:10
%       disp(x)
%   end
% 
%   for x = 1:10
%       disp(x)
%   end
% 

function Z=SWE_Algorithm(EO_BT_Cor1,EO_BT_Cor2)

[nscans,npoints,band]=size(EO_BT_Cor1); 

% for i=1:nscans
%     for j=1:npoints
%         Z(i,j)=EO_BT_Cor1(i,j);
%     end
%%
% 
%   for x = 1:10
%       disp(x)
%   end
% 
%   for x = 1:10
%       disp(x)
%   end
% 
% 
% end


%EO_BT data is stored in the data type of int16, thus it needs to be
%transform into true BT value with equation: BT=a*EO_BT+b).
a=0.01;     %Slope 
b=327.68;   %Intercept 
c=4.8;      %c=4.8 mm/K 

DP_demo=a*(EO_BT_Cor1-EO_BT_Cor2)*c; % Equation BT=a*EO_BT+b is invovled here.
Z=DP_demo;
Z(DP_demo<0)=0;
Z(DP_demo>=400)=NaN;