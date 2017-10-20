function phi = Phi(x)
% calculate the cumulative standard normal distribution

% We may be getting values of x which are complex. These will cause the
% erf() function to thrown an error. These complex numbers (probably)
% correspond to parameter values which are out of range (eg negative, for
% postivei valued distrubutions only). While these parameter values are
% later ignored (as their log prob will be -inf) we need to allow for them
% to be evaluated without throwing an error.
%x = real(x);

%phi = normcdf(scaledDifference, 0, 1); % SLOW
phi = 0.5*erf(x/sqrt(2)) + 0.5; % FAST
end
