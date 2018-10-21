function model = MainForceModel()

model.Params = ParamsTemplet();
model.Params.TradeFrequency = 1;
model.Params.StartDate = 20180101;        % 回测开始时间
model.Params.EndDate = 20181012;    % 回测结束时间

model.Params.IsEventsDriven = 1;    % 时间驱动

model.Factor = ProcessedFactor(@MainForceTrace,{20},@DropFactorThatRiseTooFast,{0.09},@GetPriceForFactor,{},@GetShareForFactor,{},...
    @DropFactorWhichNew,{250});
model.Factor.MarketValue = model.Factor.Open.*model.Factor.FloatAShare;

model.Factor = model.Factor(model.Factor.TradeDays>=model.Params.StartDate&model.Factor.TradeDays<=model.Params.EndDate,:);

% 剔除ST
model.Factor = DropFactorWhichST(model.Factor);

% 剔除当天不能够交易的因子，交易状态不为‘交易’
model.Factor = CircleAccordingStockCodes(unique(model.Factor.StockCode),@DropFactorWhichCannotTrade);
function Output = DropFactorWhichCannotTrade(StockCode)
    Factor = model.Factor(strcmp(model.Factor.StockCode,StockCode),:);
    stockdata = GetStockDailyData(model.Params.DataPath.StockDailyData,StockCode,'TRADE_STATUS',num2cell(Factor.TradeDays));
    Output = Factor(strcmp(stockdata.TRADE_STATUS,'交易'),:);
end

end