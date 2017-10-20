function plotUtilityFunction(obj, thetaStruct, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('thetaStruct',@isstruct_or_table);
% p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@istable);
p.addParameter('pointEstimateType','mean',@isstr);
% p.addParameter('maxDelay', [], @isscalar);
p.addParameter('utility_func_function_handle','', @(x) isa(x,'function_handle'))
p.parse(thetaStruct, varargin{:});
data = p.Results.data;

plotCurve(data, thetaStruct, p.Results.utility_func_function_handle, p)
%plotData(data);
formatAxes(data, p);
end


function plotCurve(data, thetaStruct, utility_func_function_handle, p)


% create set of rewards to calculate & plot ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xVals = linspace(-100, 100, 100);

% evaluate and plot just the first N particles
N = 200;
fnames = fieldnames(thetaStruct);
for n=1:numel(fnames)
    thetaStruct.(fnames{n}) = thetaStruct.(fnames{n})([1:N]);
end

% calculate discount fraction for the given theta samples ~~~~~~~~~~~~~~
prospect.reward = xVals;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
utilityOfReward = utility_func_function_handle(prospect, thetaStruct);

plot(xVals, utilityOfReward,...
    'Color',[0 0.4 1 0.1])

hold on

%% plot posterior median as black line
for n=1:numel(fnames)
    thetaStruct.(fnames{n}) = median(thetaStruct.(fnames{n}));
end
prospect.reward = xVals;
utilityOfReward = utility_func_function_handle(prospect, thetaStruct);
plot(xVals, utilityOfReward,...
    'Color', 'k',...
    'LineWidth', 2)

end


function formatAxes(data, p)
%opts = calc_opts(data, p);
xlabel('$R$', 'interpreter','Latex')
ylabel('$u(R)$', 'interpreter','Latex')

set(gca,'XAxisLocation','origin',...
    'YAxisLocation','origin',...
    'box', 'off')
% box off
% a = get(gca,'YLim');
% if opts.maxX>0
% 	xlim( [0 opts.maxX] )
% end
% ylim([0 min([a(2),10]) ])
drawnow
end

% function opts = calc_opts(data, p)
% if ~isempty(data)
% 	opts.maxlogB	= max( abs(data.R_B) );
% 	opts.maxX		= max( data.D_B ) *1.1;
% else
% 	opts.maxlogB	= 1000;
% 	opts.maxX		= 20;
% end
% 
% if ~isempty(p.Results.maxDelay)
% 	opts.maxX = p.Results.maxDelay;
% end
% end
