function SCRIPT_logk_comparison_of_methods()

addpath('darc-experiments')


%% Sort figure and subpanel arrangement
fh = figure(56); clf, drawnow
set(fh, 'WindowStyle','normal')
nrows = 4;
subplot_handles = layout([1,2,3,4; 5,6,7,8; 9,10,11,12]');
drawnow


%% Load data for the 3 example participants
examples = makeExamples();
assert(numel(examples)==3, 'expecting 3 examples')


%% Iterate over the 3 examples, plotting as we go
for n=1:numel(examples)
	fprintf('%d of %d\n',n, numel(examples))
	ind = nrows*(n-1)+1;
	process_this_example( examples(n), subplot_handles([ind:ind+(nrows-1)]))
end


% NOTE (x,y) position is in DATA units
%% Add column titles (example name)
top_plots = subplot_handles([1, 5, 9]);
for n=1:numel(top_plots)
	subplot(top_plots(n))
	h = text(365/2, 1.25, examples(n).title);
	h.HorizontalAlignment = 'center';
	h.FontWeight = 'bold';
	h.FontSize = 16;
end


%% Add row titles
row_title_labels = {'Kirby (2009)',...
	'Koffarnus & Bickel (2014)',...
	'Frye et al (2016)',...
	'our approach'};
top_plots = subplot_handles([1, 2, 3, 4]);
for n=1:numel(top_plots)
	subplot(top_plots(n))
	h = text(-100, 0.5, row_title_labels{n});
	h.Rotation = 90;
	h.HorizontalAlignment = 'center';
	h.FontWeight = 'bold';
	h.FontSize = 16;
end

% save data
save('figs/saved_data_logk_comparison_of_models')

%% Export
setAllSubplotOptions(gcf, {'LineWidth', 1.5, 'FontSize',12})
set(subplot_handles, 'PlotBoxAspectRatio',[1.5 1 1])
set(gcf,'Position',[10 10 1200 1300])
ensureFolderExists('figs')
savefig('figs/logk_comparison_of_models')
%export_fig('figs/logk_comparison_of_models', '-pdf')
export_fig('figs/logk_comparison_of_models', '-png', '-m6');

end



function process_this_example(example, subplot_handles)
%  Run models
true_logk = example.true_theta;
% [kirby_Model_to_plot, ktheta, kdata, ~,...
% 	adaptive_Model_to_plot, adaptive_theta, adaptive_data, ~]...
% 	= runKirbyAndAdaptive(true_logk);

trials = 27;
MAX_DELAY = 365;

%% Kirby example
[model, theta, data, ~] = runKirby(true_logk, 27);
subplot(subplot_handles(1))
model.plotDiscountFunction(theta(:,1),...
	'data', data,...
	'discounting_function_handle', @model.delayDiscountingFunction, ...
	'maxDelay', MAX_DELAY);
drawnow

%% KoffarnusAndBickel
[model, theta, data, ~] = runKoffarnusAndBickel(true_logk, 5);
subplot(subplot_handles(2))
model.plotDiscountFunction(theta(:,1),...
	'data', data,...
	'discounting_function_handle', @model.delayDiscountingFunction, ...
	'maxDelay', MAX_DELAY);
drawnow

%% Fry Et al
[model, theta, data, ~] = runFryeEtAl(true_logk, 5*5);
subplot(subplot_handles(3))
model.plotDiscountFunction(theta(:,1),...
	'data', data,...
	'discounting_function_handle', @model.delayDiscountingFunction, ...
	'maxDelay', MAX_DELAY);
drawnow

%% Our method
% override default delays with this
%tempD_B = default_D_B(); D_B = tempD_B(tempD_B<=190);
D_B = [1:7:MAX_DELAY];

[model, theta, data, ~] = runAdaptiveLogK(true_logk, 30,...
	'D_B', D_B);
subplot(subplot_handles(4))
model.plotDiscountFunction(theta(:,1),...
	'data', data,...
	'discounting_function_handle', @model.delayDiscountingFunction, ...
	'maxDelay', MAX_DELAY);
drawnow

end
