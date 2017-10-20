function plotDiscountSurface(obj, thetaStruct, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('thetaStruct',@isstruct);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@isstruct_or_table)
p.addParameter('pointEstimateType','mean',@isstr);
p.addParameter('discounting_function_handle','', @(x) isa(x,'function_handle'))
p.parse(thetaStruct, varargin{:});
data = p.Results.data;

plotSurface(data, thetaStruct, p.Results.discounting_function_handle, p)
plotData(data)
formatAxes(data);
end


function plotSurface(data, thetaStruct, discounting_function_handle, p)

% create set of delays to calculate & plot
N_DELAYS = 10;
if isempty(data)
	delays = linspace(0,365,N_DELAYS);
else
	max_delay_of_data = max([ data.D_A; data.D_B]);
	delays = linspace(0, max_delay_of_data, N_DELAYS);
end

opts = calc_opts(data);

%% x-axis = b
N_REWARDS = 10;
logbvec = log(logspace(1, opts.pow, N_REWARDS));

% %% y-axis = d
% dvec = linspace(0, opts.maxD, 15);

%% z-axis (AB)
[logB,D] = meshgrid(logbvec,delays); % create x,y (b,d) grid values

% -------------------------------------------------------------------------
warning('Stop doing this kludge and do it properly (see below)')
m = median(thetaStruct.m);
c = median(thetaStruct.c);
k		= exp(m .* logB + c); % magnitude effect
AB		= 1 ./ (1 + k.*D); % hyperbolic discount function
% DO IT PROPERLY, LIKE BELOW ----------------------------------------------
% delays = D;
% reward = exp(logB);
% prospect.reward = reward';
% prospect.delay = delays';
% pointEst.m = median(thetaStruct.m);
% pointEst.c = median(thetaStruct.c);
% AB = discounting_function_handle(prospect, pointEst);
% -------------------------------------------------------------------------

%% PLOT
R_B = exp(logB);
hmesh = mesh(R_B, D, AB);
% shading
hmesh.FaceColor		='w';
hmesh.FaceAlpha		=0.7;
% edges
hmesh.MeshStyle		='both';
hmesh.EdgeColor		='k';
hmesh.EdgeAlpha		=1;

% plot isolines
hold on
[c,h] = contour3(R_B, D, AB, [0.2:0.2:0.8]);
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
D=[abs(data.R_A), abs(data.R_B), data.D_A, data.D_B];
[C, ia, ic] = unique(D,'rows');
% loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset=ic==n;
	% markerSize = number of times this design has been run
	markerSize(n) = sum(myset);
	% Colour = proportion of times participant chose immediate for that design
	markerCol(n) = sum(data.R(myset)==0) ./ markerSize(n);

	x(n) = abs(data.R_B( ia(n) )); % �R_B
	y(n) = data.D_B( ia(n) ); % delay to get �R_B
	%z(n) = abs(data.R_A_over_R_B( ia(n) ).*data.R_B( ia(n) )) ./ abs(data.R_B( ia(n) ));
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
xlabel('$|R^L|$', 'interpreter','latex')
ylabel('delay $D^b$', 'interpreter','latex')
zlabel('discount factor (and $\frac{R_A}{R_B}$)', 'interpreter','latex')

opts = calc_opts(data);
view([90+45, 20])
axis vis3d
axis tight
axis square
zlim([0 1])
set(gca,...
	'XDir','reverse',...
	'XScale','log',...
	'XTick',logspace(1,opts.pow,opts.pow-1+1))
set(gca,'ZTick',[0:0.2:1])
camproj('perspective')
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
