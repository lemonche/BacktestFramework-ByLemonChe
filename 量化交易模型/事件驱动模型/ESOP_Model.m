% 创建model
function model = ESOP_Model()

% 设置模型参数
model.Params = ParamsTemplet();
model.Params.StartDate = 20180723;
model.Params.EndDate = 20180926;
model.Params.TradeFrequency = 1;
model.Params.HoldingDays = 50;
model.Params.IsEventsDriven = true;

model.Params.StockAccount.FuncToCalUseableCash = @CalAvailableCashForStock_EuqalToInitCash_Adj;

% 待回测的因子数据
Factor = ESOPSignal();

% 因子筛选
% 只选择 竞价转让
suoyin = cellfun(@(x)contains(x,'竞价转让'),Factor.stock_source,'UniformOutput',false);
Factor = Factor(cell2mat(suoyin),:);

% 股本比例大于2% 或者 员工持仓市值大于50亿
Factor = FactorSelector2(Factor,'shares_ratio',[0.02,inf]);
% Factor = FactorSelector2(Factor,'mkt_cap',[-inf,50]*10^8);

% 往前推mode.Params.HoldingDays天的员工持股计划将也要建仓
ForethDays = MoveDays(model.Params.StartDate,model.Params.HoldingDays,'Before',model.Params.WindTdays);
suoyin = Factor.TradeDays>=ForethDays&Factor.TradeDays<model.Params.StartDate;
Factor.TradeDays(suoyin) = model.Params.StartDate;

model.Factor = Factor(Factor.TradeDays>=model.Params.StartDate,:);

end
