function [model, theta, data, theta_record] = runAdaptiveLogK(true_logk, trials, varargin)
% Run a simulated experiment

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('true_logk', @isscalar);
p.addRequired('trials', @isscalar);
p.addParameter('D_B', default_D_B(), @isvector);
p.parse(true_logk, trials, varargin{:});


[alpha, epsilon] = common_parameters();

% for both these models, we estimate logk alone. Alpha and Epsilon are
% treated as fixed parameters

% Discount function (1 param model), adaptive experiment ------------------
[bvec, dvec, R_A_over_R_B] = common_adaptive_design_space();

% override dvec with supplied values
dvec = p.Results.D_B;

model = Model_hyperbolic1_time(...
	'epsilon', epsilon,...
	'R_B', bvec,...
	'D_B', dvec,...
	'R_A_over_R_B', R_A_over_R_B);

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
