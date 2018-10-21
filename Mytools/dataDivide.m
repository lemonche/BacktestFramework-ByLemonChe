% 数据分组
function Output = dataDivide(data,startlimit,endlimite)

Output = zeros(length(data),1);
for i=1:length(startlimit)
    suffix = data>=startlimit(i)&data<=endlimite(i);
    Output(suffix) = i;
end
