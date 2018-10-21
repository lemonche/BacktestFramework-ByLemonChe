% 固定信息
function Output = BasicInformation()
% 牛市时间段
Output.BullMarketTimeSpan = [19960119,19970512;
    19990517,20010613;
    20050606,20071015;
    20130624,20150612];
% 熊市时间段
Output.BearMarketTimeSpan = [19970512,19970923;
    20010613,20050606;
    20071015,20081028;
    20150612,20160127];