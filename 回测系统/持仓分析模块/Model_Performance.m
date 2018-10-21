% 分析模型整体收益回撤情况
function Performance = Model_Performance(model,varargin)

Backtest = model.Backtest;
Params = model.Params;

% 计算净值
Performance.Tdays = Backtest.Tdays;
Performance.NetValue = cumsum(Backtest.PNL)/model.Params.TotalInitCash+1;   % 净值

% 基准资产
IndexReturn = GetIndexReturn(Params.DataPath.IndexDailyData,Params.BenchAsset.AssetCode,-1,'Close/Close',num2cell(Backtest.Tdays));

% 收益指标
Performance.TotalReturn = GetTotalReturnRatio(Backtest.PNL,Params.TotalInitCash);     % 总收益率
Performance.AnnualizedTotalReturn = GetAnnualizedTotalReturnRatio(Performance.TotalReturn,Backtest.Tdays); % 年化收益率
Performance.AnnualizedSharpe = GetShapeRatio(Backtest.PNL);  % 夏普率
Performance.MaxDrawDown =  GetMaxDrawDown(Backtest.PNL,Params.TotalInitCash);    % 最大回撤
Performance.AnnualizedReturnToMaxDrawDown = Performance.AnnualizedTotalReturn/Performance.MaxDrawDown;      % 收益率回撤比
Performance.WinRatio = sum((Backtest.PNL./Params.TotalInitCash - IndexReturn.Return)>0)/length(Performance.Tdays);

% 初始化绘图元素
title = ['模型净值曲线[',num2str(Performance.Tdays(1)),'-',num2str(Performance.Tdays(end)),']'];
for i=1:2:length(varargin)
    switch varargin{i}
        case 'title'
            title = varargin{i+1};
    end
end

% 净值曲线图
figure
My_plot(@plot,[Performance.NetValue,cumsum(IndexReturn.Return)+1],'xticklabel',Performance.Tdays,'legendlabel',{'模型净值',['基准资产[',Params.BenchAsset.AssetCode,']']},...
    'title',title)