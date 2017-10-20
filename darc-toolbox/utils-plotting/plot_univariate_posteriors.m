function plot_univariate_posteriors(theta_labels, theta, true_theta, is_theta_fixed)
%plot_univariate_posteriors
%
% Plot univariate posterior distributions of all non-fixed parameter values
%
% Inputs
%   theta:	   A matrix of particles in paramter space. Each column is one
%					     parameter dimension. Each row corresponds to a particle.
%  true_theta: Either empty, or row vector of true parameters.
%   data:      A matrix of data. Each row corresponds to a particular trial.
%						   The first R-1 rows correspond to the design, the final (Rth)
%						   row is the binary response (y)
%
% FIXME Sort out the plotting functions to be common accross the different
% objects by adding some options like thetas_to_plot to classes.
%
% Ben Vincent, www.inferencelLab.com, May 2016

n_free_params = sum(~is_theta_fixed);
ind_of_free_params = find(~is_theta_fixed);

theta_posterior_mean = mean(theta,1);

%% Plot posteriors
figure(4), clf, drawnow

nDims = size(theta,2);

for n=1:n_free_params
    subplot(1,n_free_params,n)

    % plot posterior
    try
        histogram(theta(:,n),...
			'Normalization', 'pdf',...
			'FaceColor',[0 0 0],...
			'EdgeColor', 'none')
	catch
		% for backward compatability
        hist(theta(:,n),100)
    end
    axis square
	axis tight
	box off
    hold on

    % plot true param value
    if ~isempty(true_theta)
        plot(true_theta(n),0,'go')
    end

    % plot posterior mean
    plot(theta_posterior_mean(n),0,'r+')

    % formatting
    axis square
    title(theta_labels{n})
    drawnow
end

end
