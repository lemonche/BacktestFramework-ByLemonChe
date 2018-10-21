function [Output] = GetTotalReturnRatio(PNL, StartupCash)
% 策略总收益率
%   计算基本公式： TotalReturnRatio = (PV_end - PV_start)/PV_start

Output = sum(PNL)/StartupCash;