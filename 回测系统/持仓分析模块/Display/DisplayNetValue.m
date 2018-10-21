function DisplayNetValue(NetValue,Tdays)

% 绘图
plot(NetValue);
% 设置时间轴
x_tick = 1:ceil(size(Tdays,1)/30):size(Tdays,1);
set(gca,'XTick',x_tick);
set(gca,'XTickLabel',num2str(Tdays(x_tick,1)));
set(gca,'XTickLabelRotation', -45);
% 设置图例
legend('净值','location','BestOutside');
% 设置图像长宽
set(gcf,'unit','normalized','position',[0.1,0.3,0.6,0.5]);
