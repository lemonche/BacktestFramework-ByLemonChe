% 模型参数的模板
% 当模型中没有对特定参数进行赋值时，将使用默认的参数值
function Output = ParamsTemplet()      
%% 外部支持数据和因子数据
% 外部数据路径
Output.DataPath = DataPath();
% 因子数据路径
Output.FactorPath = FactorPath();

% 常用外部数据
Output.WindTdays = importdata(Output.DataPath.WindTdaysData);
Output.WindNdays = importdata(Output.DataPath.WindNdaysData);


%% 股票账户设置
Output.StockAccount.InitCash = 100*10^4;    % 股票账户初始资金
Output.StockAccount.TradeFeeRatio = 0.003;  % 股票账户交易费率
Output.StockAccount.TradePriceType = 'OPEN';    % 默认使用开盘价作为股票交易价格

Output.StockAccount.FuncToCalUseableCash = @CalAvailableCashForStock_EuqalToInitCash;   % 计算每期调仓时可自由使用的资金的方法
Output.StockAccount.FuncToCalTradeLots = @CalTradeLotsForStock_StockEqual;      % 计算每期调仓时每只股票的持仓股数

Output.StockAccount.LeastStockNum = 10;  % 当持仓股票数量少于N时，不全仓

%% 对冲账户设置
Output.HedgeAccount.IsHedge = 0;     % 是否对冲
Output.HedgeAccount.ProportionToStockAccountInitCash = 0.3;         % 对冲账户初始资金相对于股票账户初始资金的比例
Output.HedgeAccount.FuturesMultiplier = 1;      % 期货交易乘数
Output.HedgeAccount.TradeFeeRatio = 0.0006;     % 对冲账户交易费率
Output.HedgeAccount.InitCash = Output.HedgeAccount.ProportionToStockAccountInitCash*Output.StockAccount.InitCash;   % 对冲账户初始资金

Output.HedgeAccount.HedgeFunc = @DynamicHedgeToSinglePosition;   % 对冲方式
Output.HedgeAccount.AssetCode = {'000905.SH'};    % 可选择的对冲标的
Output.HedgeAccount.HedgeFuncParams = {[-0.05,0.05],'fixed',{Output.HedgeAccount.AssetCode,1}};  % 对冲函数的参数


%% 期货账户设置





%% 账户交易
Output.TotalInitCash = Output.HedgeAccount.IsHedge*Output.HedgeAccount.InitCash + Output.StockAccount.InitCash;         % 初始账户总资金
Output.StartDate = 20090101;        % 回测开始时间
Output.EndDate = Output.DataPath.DataEndDate;    % 回测结束时间
Output.TradeFrequency = 5;  % 调仓频率（单位:交易日）在实际交易中，表示每隔几天重新运行一次交易程序
Output.HoldingDays = Output.TradeFrequency; % 每次调仓后，证券持仓的时间长度，默认为不强制平仓

% 止损线
Output.StopLoss = 0;
Output.StopLossStandard = 0.02;

% 回测结束时间不得超出当前已经存在的底层数据的时间范围
Output.EndDate = min(Output.EndDate,Output.DataPath.DataEndDate);

% 事件驱动型模型
Output.IsEventsDriven = false;

%% 基准比较
% 基准资产
Output.BenchAsset.AssetCode = '000001.SH';

