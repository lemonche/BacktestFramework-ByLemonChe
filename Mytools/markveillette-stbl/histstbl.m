% 稳定分布拟合
function stblparams = histstbl(data)

[bincounts,binedges] = histcounts(data,20);
bincenters = binedges(1:end-1)+diff(binedges)/2;

hh = bar(bincenters,bincounts,1);

binwidth = binedges(2)-binedges(1); % Finds the width of each bin
area = length(data) * binwidth;

np = get(gca,'NextPlot');    
set(gca,'NextPlot','add')  

section = (min(data):(max(data)-min(data))/100:max(data))';
stblparams = stblfit(data);
stbldata = stblpdf(section,stblparams(1),stblparams(2),stblparams(3),stblparams(4));

y = area*stbldata;
plot(section,y,'r-','LineWidth',2);

set(gca,'NextPlot',np) 
end