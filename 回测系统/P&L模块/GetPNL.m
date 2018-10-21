function [Tdays,PNL,DetailInformation] = GetPNL(IdealTradeTable,Params)
% 计算组合每日盈亏和净值序列
%   示例：
%       [PNL,Tdays] = GetPNL2(IdealTradeTable,Params.StartDate,Params.EndDate,...
%    StockTradeFeeRatio,FuturesTradeFeeRatio,MultiplierOfFuturePrice)

% 生成回测交易时间序列
Tdays = sort(GetTdays(Params.StartDate, Params.EndDate, Params.WindTdays),'ascend');
NumOfTdays = length(Tdays);
% 获取回测区间内的交易流水
IdealTradeTable = IdealTradeTable((IdealTradeTable.TradeDate<=Params.EndDate)&(IdealTradeTable.TradeDate>=Params.StartDate),:);
% 获取所有合约的代码
ContractCodes = unique(IdealTradeTable.ContractCode);
NumOfContracts = length(ContractCodes);
% 每日收入表
IncomeOfAllContract = zeros(NumOfTdays,NumOfContracts);
% 每日交易费用表
TradeFeeOfAllContract = zeros(NumOfTdays,NumOfContracts);

for i=1:NumOfContracts
    % 获取每个合约的流水记录
    IdealTrade_OfEachContract = IdealTradeTable(strcmp(IdealTradeTable.ContractCode, ContractCodes{i}),:);
    % 将long_cover和short_open的Lots设为负数
    A = union(find(strcmp(IdealTrade_OfEachContract.TradeAction,'long_cover')),find(strcmp(IdealTrade_OfEachContract.TradeAction,'short_open')));
    IdealTrade_OfEachContract{A,'Lots'} = IdealTrade_OfEachContract{A,'Lots'}*(-1);

    % 找出每个交易日最后一条交易记录的位置
    LaterTradeDate = arrayShift(IdealTrade_OfEachContract.TradeDate,1,nan);
    LaterTradeDate(end) = 0;
    MatrPosOf_LastTradePerDay = find((IdealTrade_OfEachContract.TradeDate-LaterTradeDate)~=0);
    
    % 累计持仓
    IdealTrade_OfEachContract.cum_lots = cumsum(IdealTrade_OfEachContract.Lots);
    % 该合约在所有交易日上的累计持仓
    B = My_setdiff(Tdays,IdealTrade_OfEachContract.TradeDate(MatrPosOf_LastTradePerDay));
    C = sortrows([B,zeros(length(B),1)*nan;IdealTrade_OfEachContract{MatrPosOf_LastTradePerDay,{'TradeDate','cum_lots'}}],1,'ascend');
    CumLots = C(:,2);
    % 填充前值:注意！！因为存在某日某合约被完全平仓（即CumLots(i)=0）的情况，直接按照条件（CumLots(j)==0）填充前值的做法是错误的
    if isnan(CumLots(1))
        CumLots(1) = 0;
    end
    for j=2:length(CumLots)
       if isnan(CumLots(j))
           CumLots(j)=CumLots(j-1);
       end
    end
    
    if strcmp(IdealTrade_OfEachContract{1,'ContractType'},'stock')
     	if sum(CumLots<0)>0
            error('股票仓位不得为负')
     	end
        % 交易费率
        TradeFeeRatio = Params.StockAccount.TradeFeeRatio;
        % 获取每日收盘行情
        StockDailyData = GetStockDailyData(Params.DataPath.StockDailyData, ContractCodes{i}, 'CLOSE,ADJFACTOR', num2cell(Tdays));
        FuquanCloseOfStock = StockDailyData.CLOSE.*StockDailyData.ADJFACTOR;
        % 计算每日收入和交易费用
        [IncomePerStock, TradeFeePerStock] = CalculateIncomeAndFee(IdealTrade_OfEachContract, FuquanCloseOfStock, CumLots, Tdays, TradeFeeRatio);
        % 保存 
        IncomeOfAllContract(:,i) = IncomePerStock;
        TradeFeeOfAllContract(:,i) = TradeFeePerStock;
    elseif strcmp(IdealTrade_OfEachContract{1,'ContractType'},'futures')
        % 交易费率
        TradeFeeRatio = Params.HedgeAccount.TradeFeeRatio;
        % 期货乘数
        MultiplierOfFuturePrice = Params.HedgeAccount.FuturesMultiplier;
        % 获取每日股指点数
        IndexDailyData = GetIndexDailyData(Params.DataPath.IndexDailyData, ContractCodes{i}, 'CLOSE', num2cell(Tdays));
        PriceOfFutures = IndexDailyData.CLOSE*MultiplierOfFuturePrice;
        % 计算每日收入和交易费用
        [IncomePerFutures, TradeFeePerFutures] = CalculateIncomeAndFee(IdealTrade_OfEachContract, PriceOfFutures, CumLots, Tdays, TradeFeeRatio);
        % 保存
        IncomeOfAllContract(:,i) = IncomePerFutures;
        TradeFeeOfAllContract(:,i) = TradeFeePerFutures;
    else
        disp(['type of contract[',ContractCodes{i},'] connot be recognized!'])
        continue
    end
    disp(['计算P/L……',num2str(i),'/',num2str(NumOfContracts)]);
end

% 其他信息
DetailInformation.ContractCodes = ContractCodes;
DetailInformation.IncomeOfAllContract = IncomeOfAllContract;
DetailInformation.TradeFee = sum(TradeFeeOfAllContract,2);
% PNL
PNL = sum(IncomeOfAllContract,2)-DetailInformation.TradeFee;

end

%% 计算每日收入和交易费用
function [IncomePerContract, TradeFeePerContract] = CalculateIncomeAndFee(IdealTrade_OfEachContract, TradePrice, CumLots, Tdays, TradeFeeRatio)
    NumOfTdays = length(Tdays);
    IncomePerContract = zeros(NumOfTdays,1);
    TradeFeePerContract = zeros(NumOfTdays,1);
    % 找出当天和前一天持仓不全为0的序号：前后两天持仓相同，则没有交易费用；持仓为0，则没有买卖收入
    presume_cumlots = arrayShift(CumLots,-1,nan);
    presume_cumlots(1) = 0;
    Suffix_Tdays = find(CumLots~=0|presume_cumlots~=0);
    % 日收入和调仓费用不为0的情况
    for i=1:length(Suffix_Tdays)
        suffix = Suffix_Tdays(i);
        IdealTrade_OfEachContractEachDay = IdealTrade_OfEachContract(IdealTrade_OfEachContract.TradeDate==Tdays(suffix),:);
        if  suffix==Suffix_Tdays(1)
            IncomePerContract(suffix) = (TradePrice(suffix)-IdealTrade_OfEachContractEachDay{:,'Price'})'*IdealTrade_OfEachContractEachDay{:,'Lots'};  % 每日收益
            TradeFeePerContract(suffix) = IdealTrade_OfEachContractEachDay{:,'Price'}'*abs(IdealTrade_OfEachContractEachDay{:,'Lots'})*TradeFeeRatio;       % 买入卖出手续费率一致
        else
            IncomePerContract(suffix) = (TradePrice(suffix)-[TradePrice(suffix-1);IdealTrade_OfEachContractEachDay{:,'Price'}])'*[CumLots(suffix-1);IdealTrade_OfEachContractEachDay{:,'Lots'}];
            TradeFeePerContract(suffix) = IdealTrade_OfEachContractEachDay{:,'Price'}'*abs(IdealTrade_OfEachContractEachDay{:,'Lots'})*TradeFeeRatio;
        end
    end
end