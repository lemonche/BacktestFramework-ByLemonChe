function [Output]=dropDuplicate(x,unique_fields)
% 对含有nan的table根据唯一字段组(unique_fields)去重
%       例子：（根据create_date,code,org_name去重)
%       dropDuplcate(predicatedata,'create_date,code,org_name')
%   
%   说明：
%       如果table中不含有nan，则可直接使用unique函数

[~, mark]=unique(x(:,unique_fields));
Output=x(mark,:);
        