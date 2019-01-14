function SCRIPT_logk_uncertainty_reduction()

addpath('darc-experiments')
NRUNS = 500; % 500


%% Sort figure and subpanel arrangement
fh = figure(56); clf, drawnow
set(fh, 'WindowStyle','normal')


%% Run many times to get plots for information gain over trials
theta_array_kirby = [];
theta_array_ours = [];
theta_array_KB = [];
theta_array_Frye = [];
parfor runs=1:NRUNS
	fprintf('%d of %d\n', runs, NRUNS)

	% true log(k) is sampled from the prior
	true_logk = normrnd(-4.5,1); % <----------- ENSURE THIS IS EQUAL TO THE PRIOR

	[~, ~, ~, theta_record_kirby] = runKirby(true_logk, 27);
	[~, ~, ~, theta_record_ours] = runAdaptiveLogK(true_logk, 30);
	[~, ~, ~, theta_record_KB] = runKoffarnusAndBickel(true_logk, 5);
	[~, ~, ~, theta_record_Frye] = runFryeEtAl(true_logk, 6*5);

	theta_array_kirby = [theta_array_kirby theta_record_kirby];
	theta_array_ours = [theta_array_ours theta_record_ours];
	theta_array_KB = [theta_array_KB theta_record_KB];
	theta_array_Frye = [theta_array_Frye theta_record_Frye];
end

% save data
save('figs/saved_data_logk_uncertainty_reduction')

%% set up colours
% obtained from http://colorbrewer2.org/#type=qualitative&scheme=Set1&n=4
col.ours = [228 26 28]./255;
col.koff = [55 126 184]./255;
col.frye = [77 175 74]./255;
col.kirb = [152 78 163]./255;

%% plot information gain over trials
h_kirby = theta_array_kirby.plot_entropy_shaded({'FaceColor', col.kirb} , {'Color', col.kirb, 'LineWidth',3});
h_KB	= theta_array_KB.plot_entropy_shaded({'FaceColor', col.koff}, {'Color', col.koff, 'LineWidth',3});
h_Frye	= theta_array_Frye.plot_entropy_shaded({'FaceColor', col.frye}, {'Color', col.frye, 'LineWidth',3});
h_Us	= theta_array_ours.plot_entropy_shaded({'FaceColor', col.ours}, {'Color', col.ours, 'LineWidth',3});
axis tight
l = legend([h_kirby h_KB h_Frye h_Us],...
	'Kirby (2009)', 'Koffarnus and Bickel (2014)', 'Frye et al (2016)', 'Our approach');
l.FontSize = 16;
l.Box = 'off';

a = get(gca,'ylim');
ylim([0, a(2)])

drawnow


%% Export
setAllSubplotOptions(gcf, {'LineWidth', 1.5, 'FontSize',16})
set(gca, 'PlotBoxAspectRatio',[1.5 1 1])
set(gcf,'Position',[10 10 1000 800])
ensureFolderExists('figs')
savefig('figs/logk_uncertainty_reduction')
export_fig('figs/logk_uncertainty_reduction', '-png', '-m6');
%export_fig('figs/logk_uncertainty_reduction', '-pdf')
%print(gcf, '-dpdf', '-fillpage', 'figs/logk_uncertainty_reduction.pdf');
end
