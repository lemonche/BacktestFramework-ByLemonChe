function [Output] = arrayShift(A, n, replace)
% 将向量A的元素向上进n位
%   arrayShift(A,n)
index = 1:size(A,1);
shift_index = index + n;

Output = zeros(size(A))*replace;
if n>=0
    Output(index(1:end-n),:) = A(shift_index(1:end-n),:);
else
    Output(index(1-n:end),:) = A(shift_index(1-n:end),:);
end