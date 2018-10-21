% 剔除nan值的求方差的方法
function Output = My_std(x)
Output = std(x(~isnan(x)));