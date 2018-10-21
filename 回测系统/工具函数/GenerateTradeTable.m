function [TradeTable, ChiCangTable] = GenerateTradeTable(ContractNeedingTrade,kind)
% 生成交易流水，必须传入交易日期、交易代码、交易价格、交易手数
ContractNeedingTrade.Properties.VariableNames = {'tradedate','contractcode','tradeprice','tradelots'};

ChiCangTable = ContractNeedingTrade(ContractNeedingTrade.tradelots>0,:);
ChiCangTable.Properties.VariableNames = {'TradeDate','ContractCode','Price','Lots'};
% 针对对冲和股票账户交易分别设置不同TradeAction和ContractType
if strcmp(kind,'hedge')
    tradeaction = {'short_open','short_cover'};
    contracttype = 'futures';
elseif strcmp(kind,'stock')
    tradeaction = {'long_open','long_cover'};
    contracttype = 'stock';
else
    error('暂不支持该种资产的交易')
end
ChiCangTable{:,'ContractType'} = cellstr(contracttype);

% 生成交易流水
TradeTable = array2table(zeros(1,7),'VariableNames',{'TradeDate','TradeTime','ContractCode','ContractType',...
    'TradeAction','Price','Lots'});
TradeTable(1,:) = [];
contractcodes = unique(ContractNeedingTrade.contractcode);
NumOfContracts = length(contractcodes);
for i=1:NumOfContracts
    suoyin = strcmp(ContractNeedingTrade.contractcode,contractcodes{i});
    TradeDays = ContractNeedingTrade{suoyin,'tradedate'};
    TradePrice = ContractNeedingTrade{suoyin,'tradeprice'};
    % 位运算，提高速度 
    TradeLots = [0;ContractNeedingTrade{suoyin,'tradelots'}];
    Delta_TradeLots = TradeLots - arrayShift(TradeLots,-1,nan);
    Delta_TradeLots(1,:) = [];
    % 去除平仓的情况
    pingcang_suffix = (Delta_TradeLots==0);
    TradeDays(pingcang_suffix) = [];
    TradePrice(pingcang_suffix) = [];
    Delta_TradeLots(pingcang_suffix) = [];
    % 增持和减持情况
    zengchi_suffix = (Delta_TradeLots>0);
    jianchi_suffix = (Delta_TradeLots<0);
    % 
    TradeAction = {};
    TradeAction(zengchi_suffix,:) = tradeaction(1);
    TradeAction(jianchi_suffix,:) = tradeaction(2);
    
    if isempty(TradeDays)
        continue
    end
    TradeTable = [TradeTable;[num2cell(TradeDays),cellstr(repmat('09:30:00',length(TradeDays),1)),...
        cellstr(repmat(contractcodes{i},length(TradeDays),1)),cellstr(repmat(contracttype,length(TradeDays),1)),...
        TradeAction,num2cell(TradePrice),num2cell(abs(Delta_TradeLots))]];
    
    disp(['生成交易流水……',num2str(i),'/',num2str(NumOfContracts)])
end
