% 针对持仓组合的总市值的变化，动态调整对冲
function HedgeTable = DynamicHedgeToTotalPosition(StockChiCangTable,HedgeFuncParams,Settings)
% 当对冲账户市值与股票账户市值相差超过5%或者下跌到-5%时，重新调整对冲账户
ProportionToAdjustHedge = HedgeFuncParams{1};
% 股票指数池
IndexPool = HedgeFuncParams{2};
% 计算对冲比例的方式
HedgeMethod = HedgeFuncParams{3};

% 股票账户总市值
a = cell2mat(group(StockChiCangTable,'TradeDays',@(x)sum(cell2mat(x)),'MarketValue'));
AllTradeDays = a(:,1);
MarketValue = a(:,2);
% 确定需要调整对冲仓位的时间节点
SuffixToAdjustHedge = 1;
i = 2;
while 1
    CumIncreaseOfMarketValue = MarketValue(i:end)/MarketValue(i-1)-1;
    suffix = min([find(CumIncreaseOfMarketValue>=ProportionToAdjustHedge(2),1),find(CumIncreaseOfMarketValue<=ProportionToAdjustHedge(1),1)]);
    if isempty(suffix)
        break;
    end
    SuffixToAdjustHedge = [SuffixToAdjustHedge;suffix+i];
    i = suffix+i+1;
end
% 计算对冲比例，并生成对冲表
HedgeTable = table();
switch HedgeMethod
    case 'fixed'
        % 对指定的股票指数进行指定比例的对冲
        HedgeProportion = HedgeFuncParams{4};
        if length(HedgeProportion)~=length(IndexPool)
            error('需要指定与对冲标的数量相同的对冲比例')
        end
        for i=1:length(IndexPool)
            TradeDays = AllTradeDays(SuffixToAdjustHedge);
            indexdata = GetIndexDailyData(Settings.IndexDailyDataPath,IndexPool{i},'OPEN',num2cell(TradeDays));
            TradePrice = indexdata.OPEN;
            TradeLots = floor(MarketValue(SuffixToAdjustHedge).*HedgeProportion(i)./TradePrice);
            HedgeCode = cellstr(repmat(IndexPool{i},size(SuffixToAdjustHedge,1),1));
            HedgeTable = [HedgeTable;table(TradeDays,HedgeCode,TradePrice,TradeLots)];
        end
    case 'linearfit'
        
    otherwise 
        error('不支持该种方法计算对冲比例')
end

%% 持仓组合的日收益率与股票指数的多元回归计算对冲表


