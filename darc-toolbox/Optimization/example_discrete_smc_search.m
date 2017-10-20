% First run the example_pmc_run to generate some valid thetas with a known
% distribution 

example_pmc_run; % This gives an appropriate example of theta

% Assume that theta(:,1) and theta(:,2) correspond to the mean and standard
% deviation of 1D Gaussian.

% Say our preditive distribution is a bernoulli with probability
%  y = p(phi > D | theta(:,1), theta(:,2)) where 
%   phi ~ Normal(theta(:,1),theta(:,2))

log_predictive_y = @(theta,D) log(1-normcdf(D,theta(:,1),theta(:,2)));

% Permissible designs
designs_allowed = linspace(-6,6,50)';

% Call the optimizer
tic; 
[chosen_design, design_utilties] = discrete_smc_search_binary_output(log_predictive_y,designs_allowed,theta); 
toc

disp(['Design chosen ' num2str(chosen_design)]);

% Plot the utilities as a sanity chek
figure;
plot(designs_allowed,design_utilties);
xlabel('D');
ylabel('U(D)');