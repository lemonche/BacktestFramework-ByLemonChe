function  [Output] = GetMaxDrawDown(PNL, StartupCash)
% 历史回撤率,按单利计算

NetValue = cumsum(PNL) / StartupCash;
DrawDown = zeros(size(PNL,1), size(PNL,2));
for i = 1:size(PNL,1)
    for j =1:size(PNL,2)
        DrawDown(i,j) = max(NetValue(1:i,j)) - NetValue(i,j);
    end
end
Output = max(DrawDown);
