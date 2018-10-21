function [Output] = findNanFromCell(cellmatr)
% 从cell矩阵中找到nan值的序号
Output = logical(zeros(size(cellmatr)));
for i=1:length(cellmatr)
    if isnan(cellmatr{i})
        Output(i) = true;
    else
        Output(i) = false;
    end
end