function [FuturesTradeTable, FuturesChiCangTable, HedgeTable] = HedgeModule(StocksNeedingTrade,TradeDays,FuncToCalHedgeProportion,FuncParams)
% 获取对冲比例和初始对冲表
settings = Settings();
HedgeTable = FuncToCalHedgeProportion(StocksNeedingTrade,FuncParams,settings);
% 获取需要对冲的金额
StocksNeedingTrade.TotalCapital = StocksNeedingTrade.FuquanOpen.*StocksNeedingTrade.TradeLots;
HedgeTable = join(HedgeTable,StocksNeedingTrade(:,{'TradeDays','StockCode','TotalCapital'}));
% 获取期货对冲价格
HedgeCodes = unique(HedgeTable.HedgeCode);
for i=1:length(HedgeCodes)
    suoyin = strcmp(HedgeTable.HedgeCode,HedgeCodes{i});
    IndexData = GetIndexDailyData(settings.IndexDailyDataPath,HedgeCodes{i},'OPEN',num2cell(HedgeTable.TradeDays(suoyin)));
    HedgeTable{suoyin,'TradePrice'} = IndexData.OPEN;
end
% 计算交易股数
HedgeTable.TradeLots = floor(HedgeTable.TotalCapital.*HedgeTable.Proportion./HedgeTable.TradePrice);
% 汇总每天的对冲仓位
NewHedgeTable = cell2table(group(HedgeTable,{'TradeDays','HedgeCode','TradePrice'},@(x)sum(cell2mat(x)),'TradeLots'),...
    'VariableNames',{'tradedate','hedgecode','tradeprice','tradelots'});
NewHedgeTable(NewHedgeTable.tradelots==0,:) = [];
% 调整对冲表交易记录
for i=1:length(HedgeCodes)
    suoyin = strcmp(NewHedgeTable.hedgecode,HedgeCodes{i});
    [~,a,~] = intersect(TradeDays,NewHedgeTable.tradedate(suoyin));
    suffix = a+1;
    suffix = suffix(suffix<=length(TradeDays));
    CoverDays = set_diff(TradeDays(suffix),NewHedgeTable.tradedate(suoyin));
    if isempty(CoverDays)
        continue
    end
    IndexData = GetIndexDailyData(settings.IndexDailyDataPath,HedgeCodes{i},'OPEN',num2cell(CoverDays));
    NewHedgeTable = [NewHedgeTable;[num2cell(CoverDays),cellstr(repmat(HedgeCodes{i},length(CoverDays),1)),...
        num2cell(IndexData.OPEN),num2cell(zeros(size(CoverDays)))]];
end 
% 生成交易流水
[FuturesTradeTable, FuturesChiCangTable] = GenerateTradeTable(NewHedgeTable,'hedge');