% 蜡烛图
function Output = My_candle(StockData)
% StockData table类型
% 必须含有的字段名有 DateTime OPEN CLOSE HIGH LOW

Dates = datenum(num2str(StockData.DateTime),'yyyymmdd');
candle(StockData.HIGH,StockData.LOW,StockData.CLOSE,StockData.OPEN,'b',Dates)
