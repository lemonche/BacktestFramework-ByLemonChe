function StocksNeedingTrade = CalTradeLotsForStock_IndustryEqual(StocksNeedingTrade,TotalCashForStock)
% 计算股票账户持仓手数
% 行业平均分配资金

% 获取行业数据
settings = Settings();
IndustryData = importdata(settings.IndustryDataPath);
stockcodes = unique(StocksNeedingTrade.StockCode);
for i=1:length(stockcodes)
    suoyin = strcmp(StocksNeedingTrade.StockCode,stockcodes{i});
    IndustryDataForStock = GetStockIndustryByDate(stockcodes{i},StocksNeedingTrade.TradeDays(suoyin),0,IndustryData);
    StocksNeedingTrade{suoyin,{'IndustryName_C1','IndustryName_C2','IndustryName_C3'}} = IndustryDataForStock{:,3:end};
    disp(['获取所属行业数据:',stockcodes{i}])
end
% 对于没有行业数据的行，强制在该天平仓
StocksNeedingTrade{strcmp(StocksNeedingTrade.IndustryName_C3,''),'IsHold'} = 0;

% 默认持仓手数为0
StocksNeedingTrade{:,'TradeLots'} = 0;
% 每个调仓日
TradeDays = unique(StocksNeedingTrade.TradeDays);
for i=1:length(TradeDays)
    suffix = find((StocksNeedingTrade.TradeDays==TradeDays(i))&(StocksNeedingTrade.IsHold==1));
    if length(suffix)<1
        continue
    end
    Industry = unique(StocksNeedingTrade.IndustryName_C3(suffix));
    NumOfIndustry = length(Industry);
    k=[];
    for j=1:NumOfIndustry
        suoyin = strcmp(StocksNeedingTrade.IndustryName_C3(suffix),Industry{j});
        k(suoyin,:) = 1/NumOfIndustry/sum(suoyin);
    end
    StocksNeedingTrade{suffix,'TradeLots'} = floor((TotalCashForStock.*k)./StocksNeedingTrade{suffix,'FuquanOpen'});
    disp(['计算股票持仓手数:',num2str(TradeDays(i))])
end
