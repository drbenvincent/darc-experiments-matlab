function initial_thetas = generate_initial_samples(obj, n_samples)
% Create a matrix of samples from the priors of parameters which are not
% fixed, i.e. all the parameters we are going to estimate.
%
% BV

% determine which params we are estimating, the not-fixed ones
param_names = obj.params;
is_fixed = obj.is_theta_fixed;
not_fixed_param_names = param_names(~is_fixed);

% preallocate
initial_thetas = zeros(n_samples, numel(not_fixed_param_names));
% create matrix of samples of each parameter in each column
for n = 1:numel(not_fixed_param_names)
    initial_thetas(:,n) = obj.priors.(not_fixed_param_names{n}).random([n_samples,1]);
end

end
