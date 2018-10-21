% 剔除nan值的求均值的方法
function Output = My_mean(x)
Output = mean(x(~isnan(x)));