function CashBeforeTrading = CalAvailableCashForStock_EuqalToInitCash(StockAccount,Params)
% 每个调仓日期可以用于股票账户调仓的现金为初始资金
CashBeforeTrading = ones(size(StockAccount.TradeDays))*Params.StockAccount.InitCash;

end