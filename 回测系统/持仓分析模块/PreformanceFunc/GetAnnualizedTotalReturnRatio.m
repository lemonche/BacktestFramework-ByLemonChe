function [Output] = GetAnnualizedTotalReturnRatio(TotalReturn, Tdays)
% 年化总收益率,按单利计算

NumOfTdays_InOneYear = 245;
Output = TotalReturn./(length(Tdays)/NumOfTdays_InOneYear);