% 创建model
function model = S3_Model1()

% 设置模型参数
model.Params = ParamsTemplet();
model.Params.StartDate = 20180101;
model.Params.EndDate = 20181012;

% 进行股票调仓交易操作的交易日的序列
model.Params.TradeDays = GenerateTradeDays(model.Params);

% 待回测的因子数据
model.Factor = CalendarSpreadArbitrage('IC','IC1808.CFE','IC1809.CFE','5min');

end
