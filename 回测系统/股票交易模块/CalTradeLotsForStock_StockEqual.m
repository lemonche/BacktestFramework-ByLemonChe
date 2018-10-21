function StockNeedingTrade = CalTradeLotsForStock_StockEqual(StockAccount)
% 计算股票账户持仓手数
% 等权分配资金

% 默认持仓手数为0
StockNeedingTrade = StockAccount.StockNeedingTrade;
StockNeedingTrade{:,'TradeLots'} = 0;
% 每个调仓日
for i=1:length(StockAccount.TradeDays)
    CashBeforeTrading = StockAccount.CashBeforeTrading(i);
    suoyin = (StockNeedingTrade.TradeDays==StockAccount.TradeDays(i))&(StockNeedingTrade.IsHold==1);
    StockNum = sum(StockNeedingTrade{suoyin,'IsHold'});
    StockNeedingTrade{suoyin,'TradeLots'} = floor((CashBeforeTrading/StockNum)./StockNeedingTrade{suoyin,'FuquanTradePrice'});
    disp(['计算股票持仓手数:',num2str(StockAccount.TradeDays(i))])
end
