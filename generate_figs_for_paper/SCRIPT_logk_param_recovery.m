function SCRIPT_logk_param_recovery()

%% Setup
addpath('darc-experiments')
save_path = fullfile(pwd,'data');
logk_list = [-8:0.05:-1];


%% Run parameter sweeps
result_kirby			= parameter_sweep(logk_list, @param_recovery_kirby_logk, 27);
result_koffarnus		= parameter_sweep(logk_list, @param_recovery_koffarnus, 5);
result_fry				= parameter_sweep(logk_list, @param_recovery_frye, 5*4);
result_adaptive20		= parameter_sweep(logk_list, @param_recovery_adaptive_logk, 20);


%% PLOTTING
figure_handle = figure(3); clf
set(figure_handle,'WindowStyle', 'Normal')

subplot(2,2,1)
result_kirby.plot_param_recovery(), title('Kirby (2009), 27 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,2)
result_koffarnus.plot_param_recovery(), title('Koffarnus & Bickel (2014), 5 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,3)
result_fry.plot_param_recovery(), title('Frye et al (2016), 20 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,4)
result_adaptive20.plot_param_recovery(), title('Our approach, 20 trials')
axis([-8.2 -0.8 -8 0])


%% Export
setAllSubplotOptions(gcf, {'LineWidth', 2, 'FontSize', 16})
set(figure_handle, 'Position',[10 0 800 800])
ensureFolderExists('figs')
export_fig('figs/logk_param_recovery', '-pdf')
beep
end


function logk_theta_record = param_recovery_kirby_logk(true_logk, trials)
[model, theta, data, logk_theta_record] = runKirby(true_logk, trials);
end

function logk_theta_record = param_recovery_frye(true_logk, trials)
[model, theta, data, logk_theta_record] = runFryeEtAl(true_logk, trials);
end

function logk_theta_record = param_recovery_adaptive_logk(true_logk, trials)
[model, theta, data, logk_theta_record] = runAdaptiveLogK(true_logk, trials);
end

function logk_theta_record = param_recovery_koffarnus(true_logk, trials)
[model, theta, data, logk_theta_record] = runKoffarnusAndBickel(true_logk, trials);
end
