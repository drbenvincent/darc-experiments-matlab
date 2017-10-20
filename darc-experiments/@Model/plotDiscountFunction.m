function plotDiscountFunction(obj, thetaStruct, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('thetaStruct',@isstruct_or_table);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@istable);
p.addParameter('pointEstimateType','mean',@isstr);
p.addParameter('maxDelay', [], @isscalar);
p.addParameter('discounting_function_handle','', @(x) isa(x,'function_handle'))
p.parse(thetaStruct, varargin{:});
data = p.Results.data;

plotCurve(data, thetaStruct, p.Results.discounting_function_handle, p)
plotData(data);
formatAxes(data, p);
end


function plotCurve(data, thetaStruct, discounting_function_handle, p)

switch p.Results.xScale
	case{'linear'}

		% create set of delays to calculate & plot ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ~isempty(p.Results.maxDelay)
		% if isempty(data)
			xVals = logspace(-3,3,1000);
			xVals = xVals(xVals<p.Results.maxDelay);
		else
			max_delay_of_data = max([ data.D_A; data.D_B]);
			xVals = logspace(-3,4,1000);
			xVals = xVals(xVals<max_delay_of_data);
		end
		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		% evaluate and plot just the first N particles
		N = 200;
		fnames = fieldnames(thetaStruct);
		for n=1:numel(fnames)
			thetaStruct.(fnames{n}) = thetaStruct.(fnames{n})([1:N]);
		end

		% calculate discount fraction for the given theta samples ~~~~~~~~~~~~~~
		prospect.delay = xVals;
		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		dF = discounting_function_handle(prospect, thetaStruct);

		plot(xVals, dF,...
			'Color',[0 0.4 1 0.1])
        hold on
        
        %% plot posterior median as black line
        for n=1:numel(fnames)
            thetaStruct.(fnames{n}) = median(thetaStruct.(fnames{n}));
        end
        prospect.reward = xVals;
        utilityOfReward = discounting_function_handle(prospect, thetaStruct);
        plot(xVals, utilityOfReward,...
            'Color', 'k',...
            'LineWidth', 2)


	case{'log'}
		error('not yet implemented plotting discount fractions with log x-axis')
end
end


function plotData(data)
if isempty(data)
	return
end
[x, y, markerCol, markerSize] = convertDataIntoMarkers(data);
plotMarkers(x, y, markerCol, markerSize)
end

function [x, y, markerCol, markerSize] = convertDataIntoMarkers(data)
% find unique experimental designs
uniqueDesigns = [abs(data.R_A), abs(data.R_B), data.D_A, data.D_B, data.D_A, data.D_B];
[C, ia, ic] = unique(uniqueDesigns, 'rows');
%loop over unique designs (ic)
for n=1:max(ic)
	% binary set of which trials this design was used on
	myset = ic==n;
	% Size = number of times this design has been run
	F(n) = sum(myset);
	% Colour = proportion of times that participant chose immediate
	% for that design
	markerCol(n) = sum(data.R(myset)==0) ./ F(n);

	markerSize(n) = F(n);

	x(n) = data.D_B( ia(n) ); % delay to get �R_B
	y(n) = abs(data.R_A( ia(n) )) ./ abs(data.R_B( ia(n) ));
end
end

function plotMarkers(x, y, markerCol, markerSize)
hold on
for i=1:max(numel(x))
	h = plot(x(i), y(i),'o');
	h.Color='k';
	h.MarkerFaceColor=[1 1 1] .* (1-markerCol(i));
	h.MarkerSize = markerSize(i)+4;
	hold on
end
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function formatAxes(data, p)
opts = calc_opts(data, p);
xlabel('delay, $D^b$', 'interpreter','Latex')
ylabel('$d(D)$', 'interpreter','Latex')
box off
a = get(gca,'YLim');
if opts.maxX>0
	xlim( [0 opts.maxX] )
else
    x=get(gca,'XLim');
    xlim([0 a(2)])
end
ylim([0 min(10, max([a(2),1])) ])

%% Add descriptive helper text
addTextToFigure('TR', 'choose immediate', 10, 'Color', [0.7 0.7 0.7])
addTextToFigure('BL', ' choose delayed', 10, 'Color', [0.7 0.7 0.7])

drawnow
end

function opts = calc_opts(data, p)
if ~isempty(data)
	opts.maxlogB	= max( abs(data.R_B) );
	opts.maxX		= max( data.D_B ) *1.1;
else
	opts.maxlogB	= 1000;
	opts.maxX		= 20;
end

if ~isempty(p.Results.maxDelay)
	opts.maxX = p.Results.maxDelay;
end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
