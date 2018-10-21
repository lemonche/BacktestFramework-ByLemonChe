% 数据预处理模块
function StockAccount = PreprocessModule(Factor,Params)
% 初始化
StockNeedingTrade = table();

% 所有可能需要持仓的股票
StockCodes = unique(Factor.StockCode);
StockNum = length(StockCodes);
% 重新运行程序判断持仓情况的交易日期
OpenTradeDays = GenerateTradeDays(Params);
% 没有特殊情况发生时，对持仓股票强制平仓的交易日期
CloseTradeDays = MoveDays(OpenTradeDays,Params.HoldingDays,'After',Params.WindTdays);
% 所有需要调整仓位的交易日期
TradeDays = unique([OpenTradeDays;CloseTradeDays]);
% 确定证券交易的买入价格的类型
PriceType = Params.StockAccount.TradePriceType;

for i=1:StockNum
    % 获取指定的开仓日期上的该支个股的因子数据
    StockFactor = Factor(strcmp(Factor.StockCode,StockCodes{i}),:);
    % 获取交易价
    StockData = GetStockDailyData(Params.DataPath.StockDailyData,StockCodes{i},[PriceType,',ADJFACTOR,TRADE_STATUS'],num2cell(TradeDays));
    if isempty(StockData)
        warning(['当前TradeDays下没有行情数据[',StockCodes{i},']'])
        continue
    end
    TradePrice = StockData{:,PriceType};
    FuquanTradePrice = TradePrice.*StockData.ADJFACTOR;
    % 交易状态
    TradeStatus = StockData.TRADE_STATUS;
    if isa(TradeStatus,'double')
        warning(['当前TradeDays下股票交易状态为nan，无法完成交易[',StockCodes{i},']']);
        continue
    end
    % 股票代码
    StockCode = cellstr(repmat(StockCodes{i},length(TradeDays),1));
    % 设置持仓标识
    IsHold = ones(length(TradeDays),1)*nan;
    [~,suffix1,~] = intersect(OpenTradeDays,StockFactor.TradeDays);
    for j=1:length(suffix1)
        IsHold(TradeDays>=OpenTradeDays(suffix1(j))&TradeDays<CloseTradeDays(suffix1(j))) = 1;
    end
    suffix2 = find(isnan(IsHold));   % 将IsHold~=1的TradeDays设置为平仓日期
    [~,suffix3,~] = intersect(TradeDays(suffix2),CloseTradeDays(suffix1));
    IsHold(suffix2(suffix3)) = 0;
       
    NeedingTrade = table(TradeDays,StockCode,IsHold,TradePrice,FuquanTradePrice,TradeStatus);
    StockNeedingTrade = [StockNeedingTrade; NeedingTrade(~isnan(IsHold),:)];
    disp(['获取股票交易价格[',PriceType,']……',num2str(i),'/',num2str(StockNum)]);
end

% 如果是事件驱动型模型，当持仓股票没有发生改变时，不重新调整仓位
if Params.IsEventsDriven
    StockTradeDays = unique(StockNeedingTrade.TradeDays);
    for i=length(StockTradeDays):-1:2
        suoyin1 = StockNeedingTrade.TradeDays==StockTradeDays(i-1);
        suoyin2 = StockNeedingTrade.TradeDays==StockTradeDays(i);
        if isequal(StockNeedingTrade(suoyin1,{'StockCode','IsHold'}),StockNeedingTrade(suoyin2,{'StockCode','IsHold'}))
            StockNeedingTrade.IsHold(suoyin2) = nan;
        end
    end
    StockNeedingTrade = StockNeedingTrade(~isnan(StockNeedingTrade.IsHold),:);
end

% 如果强制平仓日（IsHold==0）的trade_status不为‘交易’，需要使用最近前一交易日的收盘价进行替代
suffix_NoEfficientTradeDays = find((StockNeedingTrade.IsHold==0)&(~strcmp(StockNeedingTrade.TradeStatus,'交易')));
NumOfNoEfficientTradeDays = length(suffix_NoEfficientTradeDays);
for i=1:NumOfNoEfficientTradeDays
    suffix1 = suffix_NoEfficientTradeDays(i);
    stockdata = GetStockDailyData_AtNearDate(Params.DataPath.StockDailyData,char(StockNeedingTrade{suffix1,'StockCode'}),'CLOSE,ADJFACTOR',StockNeedingTrade{suffix1,'TradeDays'},'Before'); 
    StockNeedingTrade{suffix1,'TradePrice'} = stockdata.CLOSE;
    StockNeedingTrade{suffix1,'FuquanTradePrice'} = stockdata.CLOSE*stockdata.ADJFACTOR;
    disp(['强制平仓日不是有效交易日的情况处理……',num2str(i),'/',num2str(NumOfNoEfficientTradeDays)]);
    % TradeStatus为nan的行（超过本地现有的行情数据的时间范围，或者该股票已经退市，需要假设使用最近前收盘价进行强制平仓，同时修改交易日期
    if cellfun(@(x) isa(x,'double'),StockNeedingTrade{suffix1,'TradeStatus'})
        StockNeedingTrade{suffix1,'TradeDays'} = stockdata.DateTime;
    end
end


% 设置止损线
% if Params.StopLoss
%     



% 证券交易的时间范围不能够超过已经在的底层数据的时间范围
StockAccount.TradeDays = TradeDays(TradeDays<=Params.DataPath.DataEndDate);
StockAccount.StockNeedingTrade = StockNeedingTrade(StockNeedingTrade.TradeDays<=Params.DataPath.DataEndDate,:);
