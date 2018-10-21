% 列值满足另一个set中的行的索引
function [xy, suffix_x, suffix_y] = My_intersect(x,y)

xy = intersect(x,y);
suffix_x = Suffix(x,xy);
suffix_y = Suffix(y,xy);

function Output = Suffix(x,xy)
    Output = [];
    switch class(xy)
        case 'double'
            for i=1:length(xy)
                suffix = find(x==xy(i));
                Output = [Output;reshape(suffix,length(suffix),1)];
            end
        case 'cell'
            for i=1:length(xy)
                suffix = find(strcmp(x,xy(i)));
                Output = [Output;reshape(suffix,length(suffix),1)];
            end
    end
end

end