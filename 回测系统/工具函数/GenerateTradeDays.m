% 根据Params生成需要运行交易程序的日期的序列
% 回测开始时间，回测结束时间，调参频率
function TradeDays = GenerateTradeDays(Params)

switch class(Params.TradeFrequency)
    case 'double'
        TradeDays = GetTdaysWithEqualDifference(Params.StartDate,Params.EndDate,Params.TradeFrequency,Params.WindTdays);
    case 'char'
        switch Params.TradeFrequency
            case 'monthly'
                TradeDays = GetFirstTdaysEveryMonth(Params.StartDate,Params.EndDate,Params.WindTdays);
            otherwise
                error('参数[TradeFrequency]输入错误')
        end
    otherwise
            error('参数[TradeFrequency]输入错误')
end