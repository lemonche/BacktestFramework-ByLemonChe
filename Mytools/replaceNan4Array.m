% 填充前值
function m = replaceNan4Array(m,method,varargin)
switch method
    case 'PreviousValue'% 前值
        if isnan(m(1))
            m(1)=0;
        end
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = m(suffix(i)-1);
        end
    case 'PostValue'% 后值
        if isnan(m(end))
            m(end)=0;
        end
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = m(suffix(i)+1);
        end
    case 'Zero'% 零值
        m(isnan(m)) = 0;
    case 'PreviousMean'% 前均值
        step = varargin{1};
        m(isnan(1:step))=0;
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = mean(m(suffix(i)-step:suffix(i)-1));
        end
    case 'PostMean'% 后均值
        step = varargin{1};
        m(isnan(end-step+1:end))=0;
        suffix = find(isnan(m));
        for i=1:length(suffix)
            m(suffix(i)) = mean(m(suffix(i)+1:suffix(i)+step));
        end
end 