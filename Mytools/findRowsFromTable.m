function Output = findRowsFromTable(tb,rowcell)
% 从table中找到与rowcell完全相等的行，并返回行的下标，可能有多行

tb.suffix = (1:height(tb))';
suoyin = Suoyin(tb{:,1},rowcell{1});

if length(rowcell)>1 
    for i=2:length(rowcell)
        suoyin = suoyin&(Suoyin(tb{:,i},rowcell{i}));
        if sum(suoyin)<1
            Output = [];
            return
        end
    end
end
Output = find(suoyin);


function Output = Suoyin(tbcolumn,value)
if isa(tbcolumn,'double')||isa(tbcolumn,'logical')
    Output = tbcolumn==value;
elseif isa(tbcolumn,'cell')
    Output = cellfun(@(x) isequal(x,value),tbcolumn);
else
    error('不支持该种类型的数据')
end