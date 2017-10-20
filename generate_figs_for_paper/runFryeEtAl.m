function [model, theta, data, theta_record] = runFryeEtAl(true_logk, trials)
% Run a simulated experiment

% Alpha and Epsilon are treated as fixed parameters
[alpha, epsilon] = common_parameters();

% Kirby model, 1 parameter (logk) -----------------------------------------
model = Model_hyperbolic1_time(...
	'epsilon', epsilon);

D_B = [7 30 90 180 365];
R_B = 100;
trials_per_delay = trials/numel(D_B);
model.design_override_function = makeFryEtAlGenerator(D_B, R_B, trials_per_delay);

trials = trials_per_delay * numel(D_B);

expt = Experiment(model,...
	'agent', 'simulated_agent',...
	'trials', trials,...
	'true_theta', struct('logk',true_logk, 'alpha', alpha),...
	'plotting','none');

expt = expt.runTrials();

%theta			= expt.get_theta();
theta			= expt.get_theta_as_struct();
data			= expt.data_table;
theta_record	= expt.get_specific_theta_record_parameter('logk');
end
