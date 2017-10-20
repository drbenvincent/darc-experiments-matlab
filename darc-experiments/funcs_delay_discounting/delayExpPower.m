function dF = delayExpPower(prospect, params)

if verLessThan('matlab', 'R2016b')
	dF = exp( bsxfun(@times, -params.k, bsxfun(@power,prospect.delay,params.tau) ));
else
	dF = exp(-params.k .* prospect.delay.^params.tau);
end

end
