function figMagnitudeEffectExploded(mSamples,cSamples,opts,varargin)

% plot a series of discount functions, each of which is a slice of a
% discount surface, at different reward magnitudes

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('mSamples',@isvector); 
p.addRequired('cSamples',@isvector); 
p.addRequired('opts',@isstruct);
% p.addParameter('xScale','linear',@isstr);
p.addParameter('pointEstimateType','mean',@isstr);
p.addParameter('data',[],@isstruct)
p.parse(mSamples, cSamples, opts, varargin{:});

% %% Calculate point estimates
% mcBivariate = mcmc.BivariateDistribution(mSamples,cSamples,...
% 	'shouldPlot',false,...
% 	'pointEstimateType', p.Results.pointEstimateType);
% mc = mcBivariate.(p.Results.pointEstimateType);
% m = mc(1);
% c = mc(2);
% 
% beep



%% PLOT MULITPLE DISCOUNT FUNCTIONS

% Split data into DB categories
uniqueB = sort(unique(p.Results.data.B));

for n=1:numel(uniqueB)
	
	% grab subset of data
	indicies = p.Results.data.B==uniqueB(n);
	bValue = uniqueB(n);
	dataSubset.A = p.Results.data.A(indicies); 
	dataSubset.DA = p.Results.data.DA(indicies); 
	dataSubset.B = p.Results.data.B(indicies); 
	dataSubset.DB = p.Results.data.DB(indicies); 
	dataSubset.R = p.Results.data.R(indicies); 
	
	% generate samples of logk (ie according to magnitude effect)
	% logk = m * log(B) + c
	logKsamples = mSamples .* log(bValue) +cSamples;

	% now plot discount function
	subplot(1,numel(uniqueB)+1,n)
	plotDiscountFunction(logKsamples,...
		'data',dataSubset,...
		'pointEstimateType','median')

	title( sprintf('£ B = %d',bValue) )
end

%% PLOT THE DISCOUNT SURFACE
data = p.Results.data;

subplot(1,numel(uniqueB)+1,numel(uniqueB)+1)

opts.maxlogB = max(data.B);
opts.maxD = max(data.DB);
plotDiscountSurface(mSamples, cSamples, opts, 'data', data)
