function [Output,suoyin] = My_setdiff(A,B)
% 返回A中有，而B中没有的元素
% MATLAB自带的setdiff函数会自动去重
switch class(B)
    case 'double'
        A_unique = unique(A);
        for i=1:length(A_unique)
            suoyin2 = A==A_unique(i);
            if sum(B==A_unique(i))==0
                suoyin(suoyin2) = 1;
            else
                suoyin(suoyin2) = 0;
            end
        end
    case 'cell'
        A_unique = unique(A);
        for i=1:length(A_unique)
            suoyin2 = strcmp(A,A_unique{i});
            if sum(strcmp(B,A_unique{i}))==0
                suoyin(suoyin2) = 1;
            else
                suoyin(suoyin2) = 0;
            end
            disp(i)
        end
end

Output = A(suoyin==1);