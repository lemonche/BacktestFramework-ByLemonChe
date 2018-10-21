function HedgeTable = RegressBtwSingleStockAndMultiIndex(StocksNeedingTrade,FuncParams,Params)

WindowLength = FuncParams{1};
IndexPool = FuncParams{2};
HedgeMethod = FuncParams{3};
Alpha = FuncParams{4};

% 初始化HedgeTable
HedgeTable = array2table(zeros(1,4));
HedgeTable.Properties.VariableNames = {'TradeDays','StockCode','HedgeCode','Proportion'};
HedgeTable(1,:) = [];
% 
WindTdays = importdata(Params.WindTdaysData);
TradeDays = unique(StocksNeedingTrade.TradeDays);
StartDate = MoveDays(TradeDays(1),WindowLength,'Before',WindTdays);
EndDate = MoveDays(TradeDays(end),1,'Before',WindTdays);
% 获取股票指数历史收益率
for k=1:length(IndexPool)
    indexdata = GetIndexReturn(Params.IndexDailyData,IndexPool{k},-1,StartDate,EndDate);
    IndexReturn(:,k) = indexdata.Return;
end
tic;
% 获取股票历史收益率
StockCodes = unique(StocksNeedingTrade.StockCode);
NumOfIndex = length(IndexPool);
for k=1:length(StockCodes)
    StockData = GetStockReturn(Params.StockDailyData,StockCodes{k},-1,StartDate,EndDate);
    StockData(~strcmp(StockData.TRADE_STATUS,'交易'),:) = [];
    StockData(isnan(StockData.Return),:) = [];
    suoyin = strcmp(StocksNeedingTrade.StockCode,StockCodes{k});
    TradeDays = StocksNeedingTrade.TradeDays(suoyin);
    for i=1:length(TradeDays)
        DateX = MoveDays(TradeDays(i),WindowLength,'Before',WindTdays);
        stockdata = StockData(StockData.DateTime<TradeDays(i)&StockData.DateTime>=DateX,:);
        % 匹配对应交易日的股票指数的收益率数据
        [~,suffix1,suffix2] = intersect(indexdata.DateTime,stockdata.DateTime);
        indexreturn = IndexReturn(suffix1,:);
        stockreturn = stockdata.Return(suffix2);
        % 股票收益与股票指数收益进行多元线性回归
        beta = My_lsqcurvefit(indexreturn,stockreturn);
        switch HedgeMethod
            case 'linearfit'
                proportion = beta(1:end-1) + Alpha;
            case 'linearfit&fixed'
                proportion = beta(1:end-1)*Alpha;
            case 'linearfit&corr'
                CorrelationCoefficient = corrcoef([stockreturn,indexreturn]);
                CorrelationCoefficient = CorrelationCoefficient(1,2:length(IndexPool)+1)';
                proportion = beta(1:end-1).*CorrelationCoefficient;
            otherwise
                error('不支持该种方式计算对冲比例')
        end
        HedgeTable = [HedgeTable;[num2cell(ones(NumOfIndex,1)*TradeDays(i)),cellstr(repmat(StockCodes{k},NumOfIndex,1)),...
            cellstr(IndexPool'),num2cell(proportion)]];
    end
    disp(['计算对冲比例:',StockCodes{k}])
    toc;
end
      