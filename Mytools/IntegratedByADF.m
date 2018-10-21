function [n,Output] = IntegratedByADF(x,N)

n = 0;
while n<N
    if adftest(x)
        Output = x;
        return;
    else
        x = diff(x);
        n = n+1;
    end
end

n = inf;
Output = x;