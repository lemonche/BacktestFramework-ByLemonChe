% 分析每只个股的盈利情况
function PerformanceTable = EachStock_Performance(model)

StockAccount = model.Backtest.StockAccount;
Params = model.Params;

Tdays = StockAccount.Tdays;
StockCodes = StockAccount.DetailInformation.ContractCodes;
IncomeOfAllStocks = StockAccount.DetailInformation.IncomeOfAllContract;

HoldingDays = sum(IncomeOfAllStocks~=0,1)';  % 如果持仓的前后两天的收入为0，这种情况被忽略了
ProportionOfHoldingDaysToAllTdays = HoldingDays./length(Tdays); % 持仓时间占模型总回测时长的比例
AbsoluteReturn = sum(IncomeOfAllStocks)';    % 绝对收益
AbsoluteReturnRatio = sum(IncomeOfAllStocks)'./Params.StockAccount.InitCash;  % 相对于股票账户初始资金的绝对收益率
AnnualizedReturnRatio = GetAnnualizedTotalReturnRatio(AbsoluteReturnRatio,Tdays);   % 年化收益率

StockName = GetStockName(StockCodes,importdata(Params.DataPath.StockBasicData));    % 股票名称
% Industry = GetStockIndustryByDate(StockCodes,str2num(datestr(today,'yyyymmdd')),1,importdata(Params.DataPath.StockIndustryData));   % 所属行业

PerformanceTable = table(StockCodes,StockName,HoldingDays,ProportionOfHoldingDaysToAllTdays,AbsoluteReturn,AbsoluteReturnRatio,AnnualizedReturnRatio);