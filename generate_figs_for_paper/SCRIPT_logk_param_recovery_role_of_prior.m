function SCRIPT_logk_param_recovery_role_of_prior()

%% Setup
addpath('darc-experiments')
save_path = fullfile(pwd,'data');
logk_list = [-8:0.05:-1];


%% Run parameter sweeps
result_adaptive2		= parameter_sweep(logk_list, @param_recovery_adaptive_logk, 2);
result_adaptive4		= parameter_sweep(logk_list, @param_recovery_adaptive_logk, 4);
result_adaptive8		= parameter_sweep(logk_list, @param_recovery_adaptive_logk, 8);
result_adaptive16		= parameter_sweep(logk_list, @param_recovery_adaptive_logk, 16);


%% PLOTTING
figure_handle = figure(3); clf
set(figure_handle,'WindowStyle', 'Normal')

subplot(2,2,1)
result_adaptive2.plot_param_recovery(), title('2 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,2)
result_adaptive4.plot_param_recovery(), title('4 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,3)
result_adaptive8.plot_param_recovery(), title('8 trials')
axis([-8.2 -0.8 -8 0])

subplot(2,2,4)
result_adaptive16.plot_param_recovery(), title('16 trials')
axis([-8.2 -0.8 -8 0])


%% Export
setAllSubplotOptions(gcf, {'LineWidth', 2, 'FontSize', 16})
set(figure_handle, 'Position',[10 0 800 800])
ensureFolderExists('figs')
export_fig('figs/logk_param_recovery_role_of_prior.pdf', '-pdf')
beep
end


function logk_theta_record = param_recovery_adaptive_logk(true_logk, trials)
[model, theta, data, logk_theta_record] = runAdaptiveLogK(true_logk, trials);
end
