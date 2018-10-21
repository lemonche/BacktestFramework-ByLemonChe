function [Output] = moveFunc(matr, window, func, direction)
%   对matrix矩阵进行平移操作，并对平移窗口中的数值矩阵函数操作
%       window:窗口大小
%       func: 对window中的矩阵的函数操作
%       direction: 移动方向
%   示例;
%       moveFunc(matr, window, func, direction)

N = size(matr,1);
switch direction
    case 'Before'
        for i=1:N
            if i-window(2)+1>0
                Output(i,:) = func(matr(i-window(2)+1:i-window(1),:));
            end
        end
        Output(1:window(2)-1,:) = nan;
    case 'After'
        for i=1:N
            if i+window(2)-1<=N
                Output(i,:) = func(matr(i+window(1):i+window(2)-1,:));
            end
        end
        Output = [Output; zeros(window(2)-1, size(Output,2))*nan];
end
end

