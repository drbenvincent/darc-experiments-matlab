function env_setup

%% Add toolbox paths
pathOfThisFunction = fileparts(mfilename('fullpath'));

addpath(fullfile(pathOfThisFunction,'darc-toolbox/'))

% Add all subpaths of the main toolbox (darc-toolbox) to the
% path, by calling this function
addSubFoldersToPath()

%% Add experiment-specific functions
addpath(genpath('darc-experiments/'))

% these are included as local copies in the \dependencies folder
% %% Ensure dependencies are present and added to Matlab path
% try
% 	dependencies={'https://github.com/drbenvincent/mcmc-utils-matlab' 'https://github.com/altmany/export_fig'};
% 	checkGitHubDependencies(dependencies);
% catch
% 	error('If this doesnt work, comment out the lines above, manually add the repo''s.')
% end

%% Plotting preferences
set(0, 'DefaultFigureWindowStyle', 'docked')
mcmc.setPlotTheme('fontsize',12, 'linewidth', 1)
