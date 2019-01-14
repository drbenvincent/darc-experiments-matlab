function toms_sandbox_script()

addpath('darc-experiments')


%% Sort figure and subpanel arrangement
fh = figure(56);
set(fh, 'WindowStyle','normal')
set(fh, 'units','normalized','outerposition',[0 0 1 1]); 
clf, drawnow
nrows = 1;
subplot_handles = layout([1; 2; 3]');
drawnow


%% Load data for the 3 example participants
examples = makeExamples();
examples = examples(1:3);


%% Iterate over the 3 examples, plotting as we go
for n=1:numel(examples)
	fprintf('%d of %d\n',n, numel(examples))
	ind = nrows*(n-1)+1;
	process_this_example( examples(n), subplot_handles([ind:ind+(nrows-1)]))
end

% NOTE (x,y) position is in DATA units
%% Add column titles (example name)
top_plots = subplot_handles([1, 2, 3]);
for n=1:numel(top_plots)
	subplot(top_plots(n))
	h = text(365/2, 1.25, examples(n).title);
	h.HorizontalAlignment = 'center';
	h.FontWeight = 'bold';
	h.FontSize = 16;
end

%% Export
setAllSubplotOptions(gcf, {'LineWidth', 1.5, 'FontSize',12})
%set(subplot_handles, 'PlotBoxAspectRatio',[1.5 1 1])
%set(gcf,'Position',[10 10 1200 1300])
%ensureFolderExists('figs')
%savefig('figs/logk_comparison_of_models')
%export_fig('figs/logk_comparison_of_models', '-pdf')
%export_fig('figs/logk_comparison_of_models', '-png', '-m6');

%% Second experiment

myModel = Model_hyperbolic1ME_time('epsilon', 0.01);
expt = Experiment(myModel,'agent', 'simulated_agent','true_theta', struct('m', -0.5, 'c', -5, 'alpha', 0.5));
expt = expt.runTrials();

end



function process_this_example(example, subplot_handles)
%  Run models
true_logk = example.true_theta;
% [kirby_Model_to_plot, ktheta, kdata, ~,...
% 	adaptive_Model_to_plot, adaptive_theta, adaptive_data, ~]...
% 	= runKirbyAndAdaptive(true_logk);

trials = 15;
MAX_DELAY = 365;

%% Our method
% override default delays with this
%tempD_B = default_D_B(); D_B = tempD_B(tempD_B<=190);
D_B = [1:7:MAX_DELAY];

[model, theta, data, ~] = runAdaptiveLogK(true_logk, 30,...
	'D_B', D_B);
subplot(subplot_handles(1))
model.plotDiscountFunction(theta(:,1),...
	'data', data,...
	'discounting_function_handle', @model.delayDiscountingFunction, ...
	'maxDelay', MAX_DELAY);
drawnow

end
