function dF = delayEbertPrelec(prospect, params)

if verLessThan('matlab', 'R2016b')
	dF = exp( -bsxfun(@power,...
        bsxfun(@times, params.k, prospect.delay),...
        params.tau) );
else
	dF = exp(-(params.k .* prospect.delay).^params.tau);
end

end
