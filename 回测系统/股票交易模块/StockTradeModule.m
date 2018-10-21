function StockAccount = StockTradeModule(StockAccount,Params) 

% 确定可用于股票调仓的总金额
StockAccount.CashBeforeTrading = Params.StockAccount.FuncToCalUseableCash(StockAccount,Params);
% 确定各股票持仓手数
StockAccount.StockNeedingTrade = Params.StockAccount.FuncToCalTradeLots(StockAccount);
% 生成股票交易流水
[StockAccount.TradeTable, StockAccount.HoldingTable] = GenerateTradeTable(StockAccount.StockNeedingTrade(:,{'TradeDays','StockCode','FuquanTradePrice','TradeLots'}),'stock');
