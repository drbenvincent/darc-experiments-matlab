function [model, theta, data, theta_record] = runKoffarnusAndBickel(true_logk, trials)
% Run a simulated experiment

trials = 5;

% Alpha and Epsilon are treated as fixed parameters
[alpha, epsilon] = common_parameters();

% Kirby model, 1 parameter (logk) -----------------------------------------
model = Model_hyperbolic1_time(...%'alpha', alpha,...
	'epsilon', epsilon);

R_B = 100;
model.design_override_function = makeKoffarnusBickelGenerator(R_B);

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
