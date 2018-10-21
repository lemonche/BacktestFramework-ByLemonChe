% 将残缺的时间序列填补成完整的时间序列，缺失值
function timeseries = fillTimeSeries(x,timeseries,replaceValue)

x = sortrows(x,1);
timeseries = sortrows(timeseries);

[~,b,c] = intersect(x(:,1),timeseries);
if length(b)<size(x,1)
    error('被填充的时间序列的日期应该要完全被包含于待填充的时间序列日期')
end

switch class(replaceValue)
    case 'double'   
        timeseries(:,2) = replaceValue;
        timeseries(c,2) = x(:,2);
    case 'char'
        timeseries(:,2) = nan;
        timeseries(c,2) = x(:,2);
        if replaceValue=='ForthValue'
            if isnan(timeseries(1,2))
                timeseries(1,2) = 0;
            end
            for i=2:size(timeseries,1)
                timeseries(i,2) = timeseries(i-1,2);
            end
        end
end