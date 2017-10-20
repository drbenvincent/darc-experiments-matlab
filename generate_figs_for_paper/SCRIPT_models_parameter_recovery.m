function SCRIPT_models_parameter_recovery()


%% Setup
addpath('darc-experiments')
trials = 30; %30

K = 51; % 51

% CALCULATIONS: Do parameter recovery for all models ===========================

%% Hyperbolic discounting of time (with magnitude effect)
true_m_vec = linspace(-1, -0.5, K);
true_c_vec = linspace(-0.5, -2.5, K);
[m_array, c_array] = do_param_recovery_me(trials, true_m_vec, true_c_vec);


%% Hyperbolic discounting of odds against
true_h_vec = logspace(-1,1,K);
h_array = do_param_recovery_h(trials, true_h_vec);


%% Hyperbolic discounting of time AND odds against
true_logk_vec = linspace(-8,-1,K);
true_h_vec = logspace(-1,1,K);
[TO_logk_array, TO_h_array] = do_param_recovery_time_and_odds(trials, true_logk_vec, true_h_vec);

save 'other_models_parameter_recovery.mat'
beep


%% PLOTTING
figure_handle = figure(3); clf
set(figure_handle, 'WindowStyle', 'Normal')

[figure_handle, h_row_labels, h_col_labels, h_main] = ...
make_subplot_grid({ {'time discounting', '(with magnitude effect)'},...
	{'probability', 'discounting'},...
	{'time and probabilty', 'discounting'}},...
	{'',''});

subplot(h_main(1, 1)), m_array.plot_param_recovery(), title('m'), setTickIntervals(0.25, 0.25)
subplot(h_main(1, 2)), c_array.plot_param_recovery(), title('c'), setTickIntervals(0.5, 0.5)

subplot(h_main(2, 1)), h_array.plot_param_recovery(), title('h'), %setTickIntervals(2,2)
set(gca,'XScale','log', 'YScale','log')
axis([10^-1 10^1 10^-1 10^1])
set(gca,'XTickLabel',{0.1, 1, 10},...
    'YTickLabel',{0.1, 1, 10})
delete(h_main(2, 2))

subplot(h_main(3, 1)), TO_logk_array.plot_param_recovery(), title('log(k)'), setTickIntervals(2,2)
axis([min(true_logk_vec) max(true_logk_vec) min(true_logk_vec) max(true_logk_vec)])
subplot(h_main(3, 2)), TO_h_array.plot_param_recovery(), title('h'), %setTickIntervals(2,2)
set(gca,'XScale','log', 'YScale','log')
axis([10^-1 10^1 10^-1 10^1])
set(gca,'XTickLabel',{0.1, 1, 10},...
    'YTickLabel',{0.1, 1, 10})

%% Export
figure_handle.Units = 'pixels';
set(figure_handle,'Position',[10 10 600 1000])
ensureFolderExists('figs')
savefig('figs/multiple_Model_param_recovery')
export_fig('figs/multiple_Model_param_recovery', '-pdf')
beep
end



function [m_array, c_array] = do_param_recovery_me(trials, true_m_vec, true_c_vec)
display('Hyperbolic discounting of time (with magnitude effect)')
% Define parameters

% Alpha and Epsilon are treated as fixed parameters
[alpha, epsilon] = common_parameters();

m_array = [];
c_array = [];
parfor n=1:numel(true_m_vec)
	fprintf('%d of %d\n',n, numel(true_m_vec))
	true_m = true_m_vec(n);
	true_c = true_c_vec(n);

	model = Model_hyperbolic1ME_time(...
		'epsilon', epsilon);

	expt = Experiment(model,...
		'agent', 'simulated_agent',...
		'trials', trials,...
		'true_theta', struct('m', true_m, 'c', true_c, 'alpha', alpha),...
		'plotting','none');

	expt = expt.runTrials();

	m	= expt.get_specific_theta_record_parameter('m');
	m_array = [m_array m];

	c	= expt.get_specific_theta_record_parameter('c');
	c_array = [c_array c];

end
end


function h_array = do_param_recovery_h(trials, true_h_vec)
display('Hyperbolic discounting of log odds')

% Alpha and Epsilon are treated as fixed parameters
[alpha, epsilon] = common_parameters();

h_array = [];
parfor n=1:numel(true_h_vec)
	fprintf('%d of %d\n',n, numel(true_h_vec))
	true_h = true_h_vec(n);

	model = Model_hyperbolic1_prob(...
		'epsilon', epsilon,... % fixed value
		'R_B', 100);

	expt = Experiment(...
		model,...
		'agent', 'simulated_agent',...
		'trials', trials,...
		'true_theta', struct('h', true_h, 'alpha', alpha),...
		'plotting','none');

	expt = expt.runTrials();

	h	= expt.get_specific_theta_record_parameter('h');
	h_array = [h_array h];
end


end



function [logk_array, h_array] = do_param_recovery_time_and_odds(trials, true_logk_vec, true_h_vec);
display('Hyperbolic discounting of time AND log odds against')

% Alpha and Epsilon are treated as fixed parameters
[alpha, epsilon] = common_parameters();

logk_array = [];
h_array = [];
parfor n=1:numel(true_logk_vec)
	fprintf('%d of %d\n',n, numel(true_logk_vec))
	true_logk = true_logk_vec(n);
	true_h = true_h_vec(n);

	model = Model_hyperbolic1_time_and_prob(...
		'epsilon', epsilon);

	expt = Experiment(...
		model,...
		'agent', 'simulated_agent',...
		'trials', trials,...
		'true_theta', struct('logk', true_logk, 'h', true_h, 'alpha', alpha),...
		'plotting','none');

	expt = expt.runTrials();

	logk	= expt.get_specific_theta_record_parameter('logk');
	logk_array = [logk_array logk];

	h	= expt.get_specific_theta_record_parameter('h');
	h_array = [h_array h];

end
end
