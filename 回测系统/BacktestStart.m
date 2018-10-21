% 开始回测
function model = BacktestStart(model)

disp('正在运行模型')
disp(model.Params)

% 因子数据预处理
Backtest.StockAccount = PreprocessModule(model.Factor,model.Params);
% 股票账户交易
Backtest.StockAccount = StockTradeModule(Backtest.StockAccount,model.Params);
% 计算股票账户PNL
[Backtest.StockAccount.Tdays,Backtest.StockAccount.PNL,Backtest.StockAccount.DetailInformation] = GetPNL(Backtest.StockAccount.TradeTable,model.Params);

% 对冲
if model.Params.HedgeAccount.IsHedge
    disp('进行对冲')
    % 对冲账户交易
    [Backtest.HedgeAccount.TradeTable,Backtest.HedgeAccount.ChiCangTable,Backtest.HedgeAccount.HedgeTable] = DynamicHedgeModule(Backtest.StockAccount.StockNeedingTrade,model.Params);
    % 计算对冲账户PNL
    [Backtest.HedgeAccount.Tdays,Backtest.HedgeAccount.PNL,Backtest.HedgeAccount.DetailInformation] = GetPNL(Backtest.HedgeAccount.TradeTable,model.Params);
    PNL = Backtest.StockAccount.PNL + Backtest.HedgeAccount.PNL;
else
    PNL = Backtest.StockAccount.PNL;
end

Backtest.Tdays = Backtest.StockAccount.Tdays;
Backtest.PNL = PNL;
model.Backtest = Backtest;