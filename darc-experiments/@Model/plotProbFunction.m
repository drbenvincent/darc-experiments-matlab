function plotProbFunction(obj, thetaStruct, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('thetaStruct',@isstruct_or_table);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@istable);
p.addParameter('pointEstimateType','mean',@isstr);
p.addParameter('discounting_function_handle','', @(x) isa(x,'function_handle'))
p.parse(thetaStruct, varargin{:});
data = p.Results.data;

plotCurve(data, thetaStruct, p.Results.discounting_function_handle, p)
plotData(data);
formatAxes(data);
end


function plotCurve(data, thetaStruct, discounting_function_handle, p)

switch p.Results.xScale
	case{'linear'}
		
		xProbVector = linspace(10^-4, 1, 1000);
		xOddsVector = prob2oddsagainst(xProbVector);
		
% 		% create set of probs to calculate & plot ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 		if isempty(data)
% 			xOddsVector = linspace(0,100,1000);
% 		else
% 			xOddsVector = linspace(0,100,1000);
% %             % zoom to data (only useful with the odds discounting type plot)
% % 			xOddsVector = xOddsVector( xOddsVector < max(prob2oddsagainst(data.P_B)));
% 		end
% 		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        %% Plot calibration line for h = 1 = risk neutral
        risk_neutral = 1 ./ (1+1.*xOddsVector); % hyperbolic discounting function
		
		% converting x axis from odds to probability makes it like the
		% traditional "probability weighting plot", as opposed to the
		% "discounting of odds plot"
        plot(oddsagainst2prob(xOddsVector), risk_neutral, '--',...
            'Color', [0.7 0.7 0.7],...
            'LineWidth', 4)
        hold on
        
        % evaluate and plot just the first N particles
        N = 200;
        fnames = fieldnames(thetaStruct);
		for n=1:numel(fnames)
			thetaStruct.(fnames{n}) = thetaStruct.(fnames{n})([1:N]);
		end
		
		% calculate discount fraction for the given theta samples ~~~~~~~~~~~~~~
		prospect.prob = xProbVector;
		% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		dF = discounting_function_handle(prospect, thetaStruct);
		
		plot(oddsagainst2prob(xOddsVector), dF,...
			'Color',[0 0.4 1 0.1])
        hold on
        
        %% plot posterior median as black line
        for n=1:numel(fnames)
            thetaStruct.(fnames{n}) = median(thetaStruct.(fnames{n}));
        end
        prospect.prob = xProbVector;
        utilityOfReward = discounting_function_handle(prospect, thetaStruct);
        plot(oddsagainst2prob(xOddsVector), utilityOfReward,...
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
plotMarkers(oddsagainst2prob(x), y, markerCol, markerSize)
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [x, y, markerCol, markerSize] = convertDataIntoMarkers(data)
% find unique experimental designs
uniqueDesigns = [abs(data.R_A), abs(data.R_B), data.P_A, data.P_B, data.D_A, data.D_B];
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
	
	x(n) = prob2oddsagainst(data.P_B( ia(n) ));
	y(n) = abs(data.R_A( ia(n) )) ./ abs(data.R_B( ia(n) ));
end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
function formatAxes(data)
opts = calc_opts(data);
xlabel('odds against Prospect B', 'interpreter','Latex')
xlabel('objective probability, $P$', 'interpreter','Latex')
ylabel('$\pi(P)$', 'interpreter','Latex')
box off
% a = get(gca,'YLim');
% if opts.maxX > 0
% 	xlim( [0 opts.maxX*1.1] )
% else
%     x=get(gca,'XLim');
%     xlim([0 a(2)])
% end
xlim([0 1])
ylim([0 1])

%% Add descriptive helper text
addTextToFigure('TL', 'risk seeking domain', 10)
addTextToFigure('BR', 'risk avoidant domain', 10)

drawnow
end

function opts = calc_opts(data)
if ~isempty(data)
	opts.maxlogB	= max( abs(data.R_B) );
	opts.maxX		= max( prob2oddsagainst(data.P_B) );
else
	opts.maxlogB	= 1000;
	opts.maxX		= 365;
end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
