function dF = delayRachlinModified(prospect, params)
% Proposed by Vincent & Stewart, paper in progress.
% Note that kappa^s = k, or kappa = k^(1/s)

if verLessThan('matlab', 'R2016b')
	dF = 1./ (1+ ...
    bsxfun(@power,...
    bsxfun(@times, params.kappa, prospect.delay),...
    params.s));
else
	dF = 1./(1+ (params.kappa .* prospect.delay) .^ params.s);
end

end
