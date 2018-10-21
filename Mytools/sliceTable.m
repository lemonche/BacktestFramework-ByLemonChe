% 返回某列值满足特定要求的行的序号
function [tbs,suoyin] = sliceTable(tb,field,valueset)

[tags,~,tagtags] = unique(tb(:,field));
suoyin = logical(zeros(height(tb),1));
for i=1:length(valueset)
    valuetag = findValueTag(tags,valueset(i));
    suoyin = suoyin|(tagtags==valuetag);
end 
tbs = tb(suoyin,:);
    
    
function Output = findValueTag(tags,value)
 for i=1:height(tags)
     if isequal(tags{i,:},value)
         Output = i;
         return
     end
 end