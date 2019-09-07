function [T] = dilate(R,C,M,N,I,Z,ori_x,ori_y)
T_temp = uint8(zeros(R+M-1,C+N-1));
for x = 1:N
    for y = 1:M
        if Z(y,x)
            T_temp(y:y+R-1,x:x+C-1) = T_temp(y:y+R-1,x:x+C-1)+I;
        end
    end
end
T = T_temp(ori_y:ori_y+R-1,ori_x:ori_x+C-1);
end