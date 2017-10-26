function dF = delayExponential(prospect, params)
%delayExponential Exponential disconting of delay
% The present subjective value of a prospect is given by the reward multiplied by the discount fraction. This function just calculates the discount fraction.
%
% dF = v(delay)
% where
% v(delay) = exp(-k*delay)


% calc v(delay)
dF = exp( - bsxfun(@times, prospect.delay, params.k) );
end
