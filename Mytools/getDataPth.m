function Output = getDataPth()
% 返回经常使用的到的数据保存的路径，如果数据路径发生变化，那么整个策略中只需要改动这一部分即可

Output.StockDailyDataPth = 'D:\StockDailyData\TradeData\';
Output.IndexDailyDataPth = 'D:\IndexPriceData\';
Output.WindTradeDaysDataPth = 'D:\TradeCalendar\WindTdaysData.mat';
Output.WindNatureDaysDataPth = 'D:\TradeCalendar\WindNatureDaysData.mat';
Output.IndexConstituentDataPth = 'D:\IndexConstituentData\';
Output.FuturesDailyDataPth = 'D:\FuturesDailyData\';
Output.StockShareDataPth = 'D:\StockBasicData\Shares\Data\';