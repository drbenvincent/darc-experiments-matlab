function make_plots_for_paper()

env_setup();

% Additionally add the path to code to generate figures
pathOfThisFunction = fileparts(mfilename('fullpath'));
addpath('generate_figs_for_paper')

%% Run the following script files
% These are located in ~/generate_figs_for_paper

SCRIPT_logk_comparison_of_methods()

SCRIPT_logk_uncertainty_reduction()

SCRIPT_logk_param_recovery()

SCRIPT_logk_param_recovery_role_of_prior()

SCRIPT_models_parameter_recovery()

return
