function [T1,T2,T3,T4] = morpOpe(j,I)
% i: which morphological operation? 1: dilate; 2:erode; 3:open; 4:close
% j: which SE? 1:Z8; 2:Z4; 3:ZL
[R C] = size(I);
Ic = 255-I;

ori_x = 2;
ori_y = 2;
ori_x_r = 2;
ori_y_r = 2;
M = 3;
N = 3;
if j == 1
    Z = 255*ones(3);    
elseif j == 2
    Z = [0,255,0;255,255,255;0,255,0];
elseif j == 3
    Z = [255,0;255,0;255,255];
    M = 3;
    N = 2;
    ori_x_r = 1;
end
Z_r = rot90(Z,2);

% dilate
T1 = dilate(R,C,M,N,I,Z,ori_x,ori_y);
%erode
T2 = 255 - dilate(R,C,M,N,Ic,Z_r,ori_x_r,ori_y_r);
%opening
T3 = dilate(R,C,M,N,T2,Z,ori_x,ori_y);
%closing
T4_temp = dilate(R,C,M,N,I,Z_r,ori_x_r,ori_y_r);
T4 = 255 - dilate(R,C,M,N,255-T4_temp,Z,ori_x,ori_y);
end

