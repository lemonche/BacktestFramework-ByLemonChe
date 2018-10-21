% 动态对冲
function [FuturesTradeTable, FuturesChiCangTable, HedgeTable] = DynamicHedgeModule(StocksNeedingTrade,Params)
StocksNeedingTrade = sortrows(StocksNeedingTrade,{'StockCode','TradeDays'},'ascend');

% 每个交易日的股票持仓记录
StockChiCangTable = table();

% 扩充StocksNeedingTrade，将其转换为每个交易日的持仓记录，计算每个交易日时的持仓手数
StockCodes = unique(StocksNeedingTrade.StockCode);
SuoyinOfCoverDays = StocksNeedingTrade.IsHold==0;

for i=1:length(StockCodes)
    SuoyinOfStock = strcmp(StocksNeedingTrade.StockCode,StockCodes{i});
    % 该股票持仓的交易日序列
    TradeDaysOfTransction = StocksNeedingTrade.TradeDays(SuoyinOfStock);
    TradeDays = GetTdays(TradeDaysOfTransction(1),TradeDaysOfTransction(end),Params.WindTdays);
    % 每个交易日的持仓手数
    [~,a,~] = intersect(TradeDays,TradeDaysOfTransction);
    TradeLots = zeros(size(TradeDays))*nan;
    TradeLots(a,:) = StocksNeedingTrade.TradeLots(SuoyinOfStock);
    TradeLots = replaceNan4Array(TradeLots,'PreviousValue');    % 填充前值
    % 只保留平仓日的行，删除其他持仓手数为0的行
    CoverDays = StocksNeedingTrade.TradeDays(SuoyinOfStock&SuoyinOfCoverDays);
    [~,a,~] = intersect(TradeDays,CoverDays);   % 不能删除的行的索引
    TradeDays = TradeDays(sort([find(TradeLots~=0);a]));
    TradeLots = TradeLots(sort([find(TradeLots~=0);a]));
    % 每个交易日的复权开盘价
    stockdata = GetStockDailyData(Params.DataPath.StockDailyData,StockCodes{i},'CLOSE,OPEN,ADJFACTOR,TRADE_STATUS',num2cell(TradeDays));
    % 如果交易状态不为'交易',则将当天开盘价替换为最近前收盘价
    suffix = find(isnan(stockdata.OPEN)&~strcmp(stockdata.TRADE_STATUS,'交易'));
    for k=1:length(suffix)
        if suffix(k)==1
            stockdata2 = GetStockDailyData_AtNearDate(Params.DataPath.StockDailyData,StockCodes{i},'CLOSE,ADJFACTOR,TRADE_STATUS',TradeDays(1),'Before');
            stockdata.OPEN(1) = stockdata2.CLOSE;
            stockdata.ADJFACTOR(1) = stockdata2.ADJFACTOR;
        else
            stockdata.OPEN(suffix(k)) = stockdata.CLOSE(suffix(k)-1);
            stockdata.ADJFACTOR(suffix(k)) = stockdata.ADJFACTOR(suffix(k)-1);
        end
    end
    % 计算复权开盘价
    FuquanOpen = stockdata.OPEN.*stockdata.ADJFACTOR;
    StockCode = cellstr(repmat(StockCodes{i},size(TradeDays,1),1));
    % 合并到ChiCangTable
    StockChiCangTable = [StockChiCangTable;table(TradeDays,StockCode,FuquanOpen,TradeLots)];
    disp(['获取股票每个交易日的开盘价:',StockCodes{i}]);
end
% 计算股票每天市值
StockChiCangTable.MarketValue = StockChiCangTable.FuquanOpen.*StockChiCangTable.TradeLots;

% 根据市值变化动态对冲
HedgeTable = Params.HedgeAccount.HedgeFunc(StockChiCangTable,Params);
[FuturesTradeTable, FuturesChiCangTable] = GenerateTradeTable(HedgeTable,'hedge');
    