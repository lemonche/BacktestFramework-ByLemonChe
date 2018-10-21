% 针对持仓组合的总市值的变化，动态调整对冲
function NewHedgeTable = DynamicHedgeToSinglePosition(StockChiCangTable,Params)

% 当对冲账户市值与股票账户市值相差超过5%或者下跌到-5%时，重新调整对冲账户
ProportionToAdjustHedge = Params.HedgeAccount.HedgeFuncParams{1};
% 与股票指数的对冲方式
HedgeMethod = Params.HedgeAccount.HedgeFuncParams{2};
% 计算对冲比例的函数的参数
ParamsToCalProportion = Params.HedgeAccount.HedgeFuncParams{3};

% 选出需要调整对冲操作的行
StockCodes = unique(StockChiCangTable.StockCode);
SuffixToHedge = [];
for j=1:length(StockCodes)
    SuffixOfStock = find(strcmp(StockChiCangTable.StockCode,StockCodes{j}));
    MarketValue = StockChiCangTable.MarketValue(SuffixOfStock);
    % 确定需要调整对冲仓位的时间节点
    SuffixToSuffix = 1;
    i = 2;
    while i<=length(MarketValue)
        CumIncreaseOfMarketValue = MarketValue(i:end)/MarketValue(i-1)-1;
        suffix = min([find(CumIncreaseOfMarketValue>=ProportionToAdjustHedge(2),1),find(CumIncreaseOfMarketValue<=ProportionToAdjustHedge(1),1)]);
        if isempty(suffix)
            break;
        end
        SuffixToSuffix = [SuffixToSuffix;suffix+i-1];
        i = suffix+i;
    end
    SuffixToHedge = [SuffixToHedge;SuffixOfStock(SuffixToSuffix)];
    disp(['需要调整对冲仓位的行:',StockCodes{j}])
end
StocksToHedge = StockChiCangTable(SuffixToHedge,{'TradeDays','StockCode'});

% 计算对冲表
HedgeTable = table();
switch HedgeMethod
    case 'fixed' % 个股与多个股票指数固定比例对冲
        % 股票指数池
        IndexPool = ParamsToCalProportion{1};
        % 指定对冲比例
        Proportion = ParamsToCalProportion{2};
        for i=1:length(IndexPool)
            StockChiCangTable{SuffixToHedge,'HedgeCode'} = cellstr(repmat(IndexPool{i},height(StocksToHedge),1));
            StockChiCangTable{SuffixToHedge,'Proportion'} = Proportion(i);
            HedgeTable = [HedgeTable;StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'})];
        end
    case 'simpleregress'    % 个股与多个股票指数一元回归
        % 线性回归的历史时间长度
        WindowLength = ParamsToCalProportion{1};
        % 股票指数池
        IndexPool = ParamsToCalProportion{2};
        % 计算对冲比例的具体方法
        CalProportionMethod = ParamsToCalProportion{3};
        % 计算对冲比例的参数
        Alpha = ParamsToCalProportion{4};
        a = RegressBtwSingleStockAndSingleIndex(StocksToHedge,{WindowLength,IndexPool,CalProportionMethod,Alpha},Settings);
        StockChiCangTable{SuffixToHedge,'HedgeCode'} = a.HedgeCode;
        StockChiCangTable{SuffixToHedge,'Proportion'} = a.Proportion;
        HedgeTable = StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'});
    case 'multiregress'   % 个股与多个股票指数多元回归
        % 线性回归的历史时间长度
        WindowLength = ParamsToCalProportion{1};
        % 股票指数池
        IndexPool = ParamsToCalProportion{2};
        % 计算对冲比例的具体方法
        CalProportionMethod = ParamsToCalProportion{3};
        % 计算对冲比例的参数
        Alpha = ParamsToCalProportion{4};
        a = RegressBtwSingleStockAndMultiIndex(StocksToHedge,{WindowLength,IndexPool,CalProportionMethod,Alpha},Params);
        for i=1:length(IndexPool)
            suoyin = strcmp(a.HedgeCode,IndexPool{i});
            StockChiCangTable{SuffixToHedge,'HedgeCode'} = a.HedgeCode(suoyin);
            StockChiCangTable{SuffixToHedge,'Proportion'} = a.Proportion(suoyin);
            HedgeTable = [HedgeTable;StockChiCangTable(:,{'TradeDays','StockCode','MarketValue','HedgeCode','Proportion'})];
        end
    otherwise 
        error('不支持该种方法计算对冲比例')
end

HedgeTable = sortrows(HedgeTable,{'StockCode','TradeDays'},'ascend');
% 将对冲比例为0的值修改为nan
HedgeTable.Proportion(HedgeTable.Proportion==0)=nan;

% 不需要调整对冲的行，维持前一交易日的对冲仓位
HedgeCode_List = HedgeTable.HedgeCode;
MarketValue_List = HedgeTable.MarketValue;
for i=1:length(StockCodes)
    suffix = find(strcmp(HedgeTable.StockCode,StockCodes{i}));
    TradeDays = unique(HedgeTable.TradeDays(suffix));
    for j=1:length(TradeDays)
        suoyin = HedgeTable.TradeDays(suffix)==TradeDays(j);
        if ~isnan(sum(HedgeTable.Proportion(suffix(suoyin))))
            b = HedgeTable(suffix(suoyin),:);
        end
        HedgeCode_List(suffix(suoyin),:) = b.HedgeCode;
        MarketValue_List(suffix(suoyin),:) = b.MarketValue;
    end
    disp(['不需要调整对冲仓位的行:',StockCodes{i}])
end
HedgeTable.HedgeCode = HedgeCode_List;
HedgeTable.MarketValue = MarketValue_List;

% 获取期货对冲价格
HedgeCodes = unique(HedgeTable.HedgeCode);
for i=1:length(HedgeCodes)
    suoyin = strcmp(HedgeTable.HedgeCode,HedgeCodes{i});
    IndexData = GetIndexDailyData(Params.DataPath.IndexDailyData,HedgeCodes{i},'OPEN',num2cell(HedgeTable.TradeDays(suoyin)));
    HedgeTable{suoyin,'TradePrice'} = IndexData.OPEN;
    TradeLots = HedgeTable.MarketValue(suoyin).*HedgeTable.Proportion(suoyin)./IndexData.OPEN;
    HedgeTable{suoyin,'TradeLots'} = replaceNan4Array(TradeLots,'PreviousValue');
end

% 汇总每天的对冲仓位
[Gi,Gv] = group(HedgeTable,{'TradeDays','HedgeCode','TradePrice'},@(x)sum(cell2mat(x)),'TradeLots');
NewHedgeTable = cell2table([Gi,num2cell(Gv)],'VariableNames',{'TradeDays','HedgeCode','TradePrice','TradeLots'});
