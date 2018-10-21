% 个股与单只股票指数对冲，并且是相关系数最高的股票指数
function HedgeTable = RegressBtwSingleStockAndSingleIndex(StocksNeedingTrade,FuncParams,Settings)

WindowLength = FuncParams{1};
IndexPool = FuncParams{2};
HedgeMethod = FuncParams{3};
Alpha = FuncParams{4};

% 初始化HedgeTable
HedgeTable = StocksNeedingTrade(:,{'TradeDays','StockCode'});
% 
WindTdays = importdata(Settings.WindTdaysDataPath);
TradeDays = unique(StocksNeedingTrade.TradeDays);
StartDate = MoveDays(TradeDays(1),WindowLength,'Before',WindTdays);
EndDate = MoveDays(TradeDays(end),1,'Before',WindTdays);
% 获取股票指数历史收益率
for k=1:length(IndexPool)
    indexdata = GetIndexReturn(Settings.IndexDailyDataPath,IndexPool{k},-1,StartDate,EndDate);
    IndexReturn(:,k) = indexdata.Return;
end
tic;
% 获取股票历史收益率
StockCodes = unique(StocksNeedingTrade.StockCode);
for k=1:length(StockCodes)
    StockData = GetStockReturn(Settings.StockDailyDataPath,StockCodes{k},-1,StartDate,EndDate);
    StockData(~strcmp(StockData.TRADE_STATUS,'交易'),:) = [];
    StockData(isnan(StockData.Return),:) = [];
    suffix = find(strcmp(StocksNeedingTrade.StockCode,StockCodes{k}));
    TradeDays = StocksNeedingTrade.TradeDays(suffix);
    for i=1:length(TradeDays)
        DateX = MoveDays(TradeDays(i),WindowLength,'Before',WindTdays);
        stockdata = StockData(StockData.DateTime<TradeDays(i)&StockData.DateTime>=DateX,:);
        % 匹配对应交易日的股票指数的收益率数据
        [~,suffix1,suffix2] = intersect(indexdata.DateTime,stockdata.DateTime);
        indexreturn = IndexReturn(suffix1,:);
        stockreturn = stockdata.Return(suffix2);
        % 计算相关系数
        CorrelationCoefficient = corrcoef([stockreturn,indexreturn]);
        CorrelationCoefficient = CorrelationCoefficient(1,2:length(IndexPool)+1);
        [a,b] = max(CorrelationCoefficient);
        if isnan(a)
            error('相关系数不能为nan，请检查代码');
        end
        % 计算对冲比例
        switch HedgeMethod
            case 'fixed'
                proportion = Alpha;
            case 'linearfit'
                LinearFit = regstats(stockreturn,indexreturn(:,b),'linear','beta');
                proportion = Alpha + LinearFit.beta(2);
            case 'linearfit&corr'
                LinearFit = regstats(stockreturn,indexreturn(:,b),'linear','beta');
                proportion = Alpha + LinearFit.beta(2)*a;
            otherwise
                error('不支持该种方法计算对冲比例')
        end
        HedgeTable{suffix(i),'HedgeCode'} = cellstr(IndexPool{b});
        HedgeTable{suffix(i),'Proportion'} = proportion;
    end
    disp(['计算对冲比例:',StockCodes{k}])
    toc;
end
      