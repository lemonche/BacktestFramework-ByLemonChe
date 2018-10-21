% 按照每只股票进行循环依次向后的循环计算
function Factor = CircleAccordingStockCodes(StockCodes,Func,varargin)

Factor = {};
FactorSplitByStock = {};
for i=1:length(StockCodes)
    disp(['按股票代码依次计算：',StockCodes{i}])  
    
    Result = Func(StockCodes{i},varargin{:});
    if isempty(Result)
        continue
    end
    Result.StockCode = cellstr(repmat(StockCodes{i},size(Result,1),1));
    
    FactorSplitByStock = [FactorSplitByStock;Result];
    
   	% 按照每年度保存因子数据
    if size(FactorSplitByStock,1) >500000 || i==length(StockCodes)
        Factor = [Factor;FactorSplitByStock];
        FactorSplitByStock = {};
    end
end
