% 创建model
function model = S1_Model1()

% 设置模型参数
model.Params = ParamsTemplet();

model.Params.StartDate = 20090101;
model.Params.EndDate = 20181019;

% 进行股票调仓交易操作的交易日的序列
model.Params.TradeFrequency = 5;
model.Params.TradeDays = GenerateTradeDays(model.Params);

% 待回测的因子数据
% 获取市值和股票板块，剔除开盘大涨超过9%
model.Factor = ProcessedFactor(@AnalystPredicateFactor,{180,2},@DropFactorThatRiseTooFast,{0.09},@GetPriceForFactor,{},@GetShareForFactor,{},@SplitStockPlate,{});
model.Factor.MarketValue = model.Factor.Open.*model.Factor.FloatAShare;

model.Factor.TargetProfitRate = model.Factor.FuquanTargetPriceOverAll./(model.Factor.Adj.*model.Factor.Open);

% 获取调仓交易日序列范围内的因子数据
[~,suffix,~] = My_intersect(model.Factor.TradeDays,model.Params.TradeDays);
model.Factor = model.Factor(suffix,:);

% 剔除ST股票
model.Factor = DropFactorWhichST(model.Factor);

end
