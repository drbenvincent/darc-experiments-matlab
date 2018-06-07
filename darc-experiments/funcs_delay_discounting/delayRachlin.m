function dF = delayRachlin(prospect, params)

if verLessThan('matlab', 'R2016b')
	dF = 1./ (1+ bsxfun(@times,...
    params.k,...
    bsxfun(@power, prospect.delay, params.s)));
else
	dF = 1./(1+params.k .* (prospect.delay .^ params.s));
end

end
