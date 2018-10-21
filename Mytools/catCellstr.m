function [Output] = catCellstr(strlist,varargin)
% 将cellstr中的字符串拼成一个字符串
%   catCellstr(cellstr,splitchar)
if isempty(varargin)
    varargin = ',';
else
    varargin = varargin{:};
end
    

if length(strlist)<1
    Output = '';
    return
end

for i=1:length(strlist)
    switch class(strlist{i})
        case 'cell'
            strlist{i} = catCellstr(strlist{i},varargin);
        case 'double'
            strlist{i} = num2str(strlist{i});
        otherwise
            strlist{i} = char(strlist{i});
    end
end

Output = strlist{1};
for i=2:length(strlist)
    Output = [Output,varargin,strlist{i}];
end