% 按照每个交易日进行循环依次向后的循环计算
% 单独将按照交易日期的循环计算过程拿出来，可以保证各个交易日之间的独立性
% 每次循环时，函数中肯定存在的参数就是该循环对应的交易日期
function Factor = CircleAccordingTradeDays(TradeDays,Func,varargin)

TradeDays = sortrows(TradeDays,'ascend');

Factor = {};
FactorSplitByYear = {};
for i=1:length(TradeDays)
    
    Result = Func(TradeDays(i),varargin{:});
    if isempty(Result)
        disp(['按交易日依次计算：',num2str(TradeDays(i))])  
        continue
    end
    
    FactorSplitByYear = [FactorSplitByYear;Result];
    disp(['按交易日依次计算：',num2str(TradeDays(i))]) 
    
    % 按照每年度保存因子数据
    if size(FactorSplitByYear,1) >500000 || i==length(TradeDays)
        Factor = [Factor;FactorSplitByYear];
        FactorSplitByYear = {};
    end
end
