function [GroupIndex,GroupResult] = group(table, field, func, tofield)
% 根据table的某列属性进行分组，并且对分组进行函数操作
% 仅适用于对数值型的列属性进行分组

[tb,~,G] = unique(table(:,field));
value = splitapply(func,table2cell(table(:,tofield)),G);

GroupIndex = table2cell(tb);
GroupResult = value;
    