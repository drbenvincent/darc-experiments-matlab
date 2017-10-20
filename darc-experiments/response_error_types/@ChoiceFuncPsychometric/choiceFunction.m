function [p_y_equal_1] = choiceFunction(obj, VA, VB, alpha, epsilon)
% calculate response probability

scaledDifference = bsxfun(@rdivide, bsxfun(@minus,VB,VA) , alpha);
% Apply error rate, epsilon
p_y_equal_1 = bsxfun(@plus,...
    epsilon,...
    bsxfun(@times, (1-2.*epsilon), Phi(scaledDifference)));
p_y_equal_1(isnan(p_y_equal_1)) = 0;
p_y_equal_1 = max(0,p_y_equal_1);
end
