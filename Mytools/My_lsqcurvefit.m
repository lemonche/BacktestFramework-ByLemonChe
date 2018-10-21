function [beta] = My_lsqcurvefit(X,y)

NumOfVariables = size(X,2);

switch NumOfVariables
    case 1
        func = @(c,x)c(1)*x(:,1)+c(2);
    case 2
        func = @(c,x)c(1)*x(:,1)+c(2)*x(:,2)+c(3);
    case 3
        func = @(c,x)c(1)*x(:,1)+c(2)*x(:,2)+c(3)*x(:,3)+c(4);
    otherwise
        error('解释变量个数超过限制（最多3个）')
end

lb = [ones(1,NumOfVariables)*0, -0.1];
ub = [ones(1,NumOfVariables)*3, 0.1];
initvalue = [ones(1,NumOfVariables)*0.5, 0];
options = optimoptions('lsqcurvefit','Display','none');

beta = lsqcurvefit(func,initvalue,X,y,lb,ub,options);
beta = beta';
