function [CashBeforeTrading,StockNum] = CalAvailableCashForStock_EuqalToInitCash_Adj(StockAccount,Params)
% 每个调仓日期可以用于股票账户调仓的现金为初始资金
% 但当前持仓股票数量少于指定的股票数量时，不进行满仓操作
[Gi,StockNum] = group(StockAccount.StockNeedingTrade(StockAccount.StockNeedingTrade.IsHold==1,:),'TradeDays',@length,'StockCode');
StockNum = fillTimeSeries([cell2mat(Gi),StockNum],StockAccount.TradeDays,0);    % 如果某天不持仓，将StockNum设置为0

CashBeforeTrading = min(StockNum(:,2),Params.StockAccount.LeastStockNum)./Params.StockAccount.LeastStockNum*Params.StockAccount.InitCash;
end