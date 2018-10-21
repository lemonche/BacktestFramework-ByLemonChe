% 将cellstr中的某个元素换乘另一种元素
function x = replaceCellstr(x,str1,str2)
suoyin = strcmp(x,str1);
x(suoyin) = {str2};
end
