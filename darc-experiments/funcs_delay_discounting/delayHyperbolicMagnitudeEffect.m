function dF = delayHyperbolicMagnitudeEffect(prospect, params)

%% Magnitude effect: log(k) = m * log(|reward|) + c    
new_params.logk = bsxfun(@plus, params.m.*log(prospect.reward), params.c);
assert(isvector(new_params.logk))

% now call standard hyperbolic function
dF = delayHyperbolic(prospect, new_params);
end
