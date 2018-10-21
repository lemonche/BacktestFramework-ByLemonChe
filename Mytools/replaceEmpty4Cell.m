function [Output] = replaceEmpty4Cell(x)
    for i=1:length(x)
       if isempty(x{i})
           x{i}=nan;
       end
    end
    Output = x;
end