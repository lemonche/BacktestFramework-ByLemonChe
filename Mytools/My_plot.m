function [Output]  = My_plot(func, matr, varargin)
% 对某列数据进行统计描述，必须为数值矩阵

if 0~=mod(length(varargin),2)
    error('参数输入错误')
end

matr_mean = mean(matr);
matr_std = std(matr);
matr_max = max(matr);
matr_min = min(matr);

hold on
func(1:size(matr,1), matr)

params = varargin(1:2:end);
a=get(gca);

% 设置legend
xuhao_legendlabel = find(ismember(params,'legendlabel'),1);
if isempty(xuhao_legendlabel)
    legendlabel = 1:size(matr,2);
else
    legendlabel = varargin{xuhao_legendlabel*2};
end
if isa(legendlabel,'double')
    legendlabel = arrayfun(@(x)cellstr(num2str(x)),legendlabel);
end
legend(legendlabel,'location','BestOutside')


% 设置text
xuhao_isshow = find(ismember(params,'showtext'),1);
if ~isempty(xuhao_isshow)
    showtext = varargin{xuhao_isshow*2};
    
    x=a.XLim;%获取横坐标上下限
    y=a.YLim;%获取纵坐标上下限
    for i=1:size(matr,2)
        k=[0.1,1.02-i*0.05];%给定text相对位置
        x0=x(1)+k(1)*(x(2)-x(1));%获取text横坐标
        y0=y(1)+k(2)*(y(2)-y(1));%获取text纵坐标
        textout = [legendlabel{i}, '  平均值: ',num2str(matr_mean(i)),...
            '  标准差: ',num2str(matr_std(i)),...
            '  最大值: ',num2str(matr_max(i)),...
            '  最小值: ',num2str(matr_min(i))];
        text(x0,y0,textout,'FontSize',10);
    end
end
        

% 设置xticklabel
xuhao_numofxtick = find(ismember(params, 'xticknum'),1);
if ~isempty(xuhao_numofxtick)
    numofxtick = varargin{xuhao_numofxtick*2};
else
    numofxtick = 50;
end
xuhao_xticklabel = find(ismember(params, 'xticklabel'),1);
if ~isempty(xuhao_xticklabel)
    xticklabel = varargin{xuhao_xticklabel*2};
    if isa(xticklabel,'double')
        xticklabel = cellstr(num2str(xticklabel));
    end
	xtick = 1:ceil(size(matr,1)/numofxtick):size(matr,1);
    set(gca,'xtick',xtick)
    set(gca,'xticklabel',xticklabel(xtick))
    set(gca,'xticklabelrotation',45)
end


% 设置图像长宽
set(gcf,'unit','normalized','position',[0.1,0.3,0.5,0.5]);


% 设置title
xuhao_title = find(ismember(params, 'title'),1);
if ~isempty(xuhao_title)
    title(varargin{xuhao_title*2},'FontSize',14);
end



% 设置坐标轴区间
xuhao_xlim = find(ismember(params,'xlim'),1);
if ~isempty(xuhao_xlim)
    a=get(gca);
    axis([varargin{xuhao_xlim*2}, a.YLim]);
end
xuhao_ylim = find(ismember(params,'ylim'),1);
if ~isempty(xuhao_ylim)
    a=get(gca);
    axis([a.XLim, varargin{xuhao_ylim*2}]);
end


% 添加水平线
xuhao_hline = find(ismember(params, 'hline'),1);
if ~isempty(xuhao_hline)
    yhline = varargin{xuhao_hline*2};
    for i=1:length(yhline)
        y=yhline(i);
        plot(a.XLim,[y,y],':','color','k');
    end
end


% 添加垂直线
xuhao_vline = find(ismember(params, 'vline'),1);
if ~isempty(xuhao_vline)
    xvline = varargin{xuhao_vline*2};
    for i=1:length(xvline)
        x=xvline(i);
        plot([x,x],a.YLim,'--','color','r');
    end
end