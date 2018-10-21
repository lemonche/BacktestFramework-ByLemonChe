% 选出值最大的前20%，并返回下标 
function suoyin = findTopN(x,top,varargin)
[a,b] = sort(x,'descend');
n = ceil(top*length(a));

MinN = 0;
MaxN = inf;
for i=1:length(varargin)/2
    switch varargin{i*2-1}
        case 'MinN'
            MinN = varargin{i*2};
        case 'MaxN'
            MaxN = varargin{i*2};
    end
end

if MaxN<MinN
    error('要求的最少数量值不能大于要求的最多数量值')
else
    n = min(max(min(MaxN,n),MinN),length(x));
end
    
suffix = b(1:n);
suoyin = logical(zeros(length(x),1));
suoyin(suffix) = true;
