function plotDiscountSurface(obj, thetaStruct, varargin)
% plots prob and time discount surface

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('thetaStruct',@isstruct);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@isstruct_or_table)
p.addParameter('pointEstimateType','mean',@isstr);
p.addParameter('prob_discounting_function_handle','', @(x) isa(x,'function_handle'))
p.addParameter('time_discounting_function_handle','', @(x) isa(x,'function_handle'))
p.parse(thetaStruct, varargin{:});
data = p.Results.data;

plotSurface(data, thetaStruct, p.Results.prob_discounting_function_handle, p.Results.time_discounting_function_handle, p)
plotData(data)
formatAxes(data);
title({'P_A chance of �R_A in D_A days','P_B chance of �R_B in D_B days'})
end


function plotSurface(data, thetaStruct, probDiscountingFunctionFH, timeDiscountingFunctionFH, p)

% create set of delays to calculate & plot
N_DELAYS = 10;
N_ODDS = 12;
if isempty(data)
	delays = linspace(0,365,N_DELAYS);
else
	max_delay_of_data = max([ data.D_A; data.D_B]);
	delays = linspace(0, max_delay_of_data, N_DELAYS);
end

if isempty(data)
	odds = linspace(0, 20, N_ODDS);
else
	odds = linspace(0, max(prob2oddsagainst(data.P_B)), N_ODDS);
end

% Evaluate only the posterior median
fnames = fieldnames(thetaStruct);
for n=1:numel(fnames)
	thetaStruct.(fnames{n}) = median(thetaStruct.(fnames{n}));
end

warning('CREATE THIS NESTED PARAMETER STRUCTURE AUTOMATICALLY')
nestedParamStruct.prob.h = thetaStruct.h;
nestedParamStruct.delay.logk = thetaStruct.logk;

%opts = calc_opts(data);

% create grid of values
[odds_grid, delays_grid] = meshgrid(odds,delays); % create x,y (b,d) grid values

warning('this is duplication of model.calcPresentSubjectiveValue()')
prospect.reward = [];
prospect.delay = delays_grid(:);
prospect.prob = oddsagainst2prob(odds_grid(:));
V = ...
	probDiscountingFunctionFH(prospect, nestedParamStruct.prob) .* ...
	timeDiscountingFunctionFH(prospect, nestedParamStruct.delay);
V = reshape(V, size(odds_grid));



%% PLOT
hmesh = mesh(odds_grid, delays_grid, V);
% shading
hmesh.FaceColor		='w';
hmesh.FaceAlpha		=0.7;
% edges
hmesh.MeshStyle		='both';
hmesh.EdgeColor		='k';
hmesh.EdgeAlpha		=1;

% plot isolines
hold on
[c,h] = contour3(odds_grid, delays_grid, V, [0.2:0.2:0.8]);
h.LineColor = 'k';
h.LineWidth = 4;
end

function plotData(data)
if isempty(data)
	return
end
[x,y,z,markerCol,markerSize] = convertDataIntoMarkers(data);
plotMarkers(x, y, z, markerCol, markerSize)
end

function [x,y,z,markerCol,markerSize] = convertDataIntoMarkers(data)
% find unique experimental designs
uniqueDelays = [abs(data.R_A), abs(data.R_B), data.D_A, data.D_B, data.D_A, data.D_B];
[C, ia, ic] = unique(uniqueDelays,'rows');
% loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset=ic==n;
	% markerSize = number of times this design has been run
	markerSize(n) = sum(myset);
	% Colour = proportion of times participant chose immediate for that design
	markerCol(n) = sum(data.R(myset)==0) ./ markerSize(n);
	
	x(n) = prob2oddsagainst( data.P_B( ia(n) ) ); % odds against
	y(n) = data.D_B( ia(n) ); % delay
	z(n) = abs(data.R_A(ia(n))) ./ abs(data.R_B( ia(n)));
end
end

function plotMarkers(x, y, z, markerCol, markerSize)
hold on
for i=1:numel(x)
	h = stem3(x(i), y(i), z(i));
	h.Color='k';
	h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
	h.MarkerSize = markerSize(i)+4;
	hold on
end
end

function formatAxes(data)
%opts = calc_opts(data);
xlabel('Odds against, $\frac{1-P^B}{P^B}$', 'interpreter','latex')
ylabel('delay $D^B$', 'interpreter','latex')
zlabel('discount factor (and $\frac{R_A}{R_B}$)', 'interpreter','latex')

view([90+45, 20])
axis vis3d
axis tight
axis square
zlim([0 1])
camproj('perspective')
set(gca,'ZTick',[0:0.2:1])
end

function opts = calc_opts(data)
if ~isempty(data)
	opts.maxlogB	= max( abs(data.R_B) );
	opts.maxD		= max( data.D_B );
else
	opts.maxlogB	= 1000;
	opts.maxD		= 365;
end

% what does this even do?
opts.nIndifferenceLines = 10;
pow=1; while opts.maxlogB > 10^pow; pow=pow+1; end
opts.pow = pow;
end
