function [ I_thresholded, I_bernsen, I_otsu, ...
    I_hysthresh, I_colorthresh ] ...
    = thresh(I0, t1, t2, N)
    
I = rgb2gray(I0);
I = imgaussfilt(I,3);
I = wiener2(I);

I_bernsen = bernsen(I, [97,97]);

% [J1,~,~,~] = morpOpe_grayscale(2,uint8(I1)*255);
% [I1] = reconGray(I1,J1,2);
% I1 = I1/255;
level = graythresh(I);
I_otsu = im2bw(I,level*1.5);
% I1 = I1.*uint8(I_thresholded_1);
% I_thresholded_1 = [];
% [~,C] = size(I1);
% interv = floor(C/N);
% for i = 1:N
%     if i ~= N
%         J = I1(:,interv*(i-1)+1:interv*i);
%     else
%         J = I1(:,interv*(i-1)+1:end);
%     end
% %     T1 = t1 * mean(double(J(:)));
% %     T2 = t2 * mean(double(J(:)));
% %     J_thresholded_1 = hysthresh(J, T1, T2);
%     J_thresholded_1 = J<(t1*mean(double(J(:))));
%     I_thresholded_1 = [I_thresholded_1,J_thresholded_1];
% end
% I_thresholded_1 = ~I_thresholded_1;

T1 = t1 * mean(double(I(:)));
T2 = t2 * mean(double(I(:)));
I_hysthresh = hysthresh(I, T1, T2);

I2 = rgb2hsv(I0);
I_colorthresh = I2(:,:,3)<0.5;

I_thresholded = (~I_bernsen) .* (~I_otsu) .* (~I_hysthresh) .* I_colorthresh;

I_thresholded = uint8(I_thresholded)*255;
se = [1,2,1,2];
ope = [2,2,1,1];
for i = 1:4
    [J_temp(:,:,1),J_temp(:,:,2),~,~] = morpOpe(se(i),I_thresholded);
    I_thresholded = J_temp(:,:,ope(i));
end
I_thresholded = I_thresholded/255;
% I_thresholded = ~I_thresholded;

end

