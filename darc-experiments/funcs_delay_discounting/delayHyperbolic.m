function dF = delayHyperbolic(prospect, params)
%delayDiscountingFunction Calculates the discount fraction
% The present subjective value of a prospect is given by the reward multiplied by the discount fraction. This function just calculates the discount fraction.
%
% dF = v(delay)
% where
% v(delay) = 1 / (1+k.delay)


% calc v(delay)
dF = bsxfun(@rdivide, 1,...
    (1 + bsxfun(@times, prospect.delay, exp(params.logk))));
end
