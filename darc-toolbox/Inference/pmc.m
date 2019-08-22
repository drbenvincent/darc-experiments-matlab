function [theta, log_Z, ess] = pmc(p_log_pdf,q_log_pdf,q_sample,theta_start,n_steps,b_display, data)
%pmc Population Monte Carlo inference scheme
%
% Carries out a number of iterations of population monte carlo (PMC) without
% proposal adaptation.  See "Population Monte Carlo" (Cappe et al 2012).
% In short PMC without adaptation equates to SMC on a stationary target
% distribtuion.  
%
% Inputs
%    p_log_pdf  :  Anonymous function giving the log pdf of the target
%                  distribution p.  Need not be normalized.  Should take a
%                  single matrix as arguments where different rows are
%                  different samples and different columns are different
%                  dimensions
%    q_log_pdf  :  Anonymous function giving the log pdf of the proposal
%                  distribution q.  Must be correctly normalized.  Should
%                  take two matrices as arguments - the first is the
%                  start points and the second is the sampled points.
%    q_sample   :  Function for sampling a transition.  Takes a single
%                  argument corresponding to a matrix of starting points.
%                  Must correspond to a draw from q_log_pdf.
%    theta_start : A matrix of starting points for the sampler
%    n_steps    :  Number of transitions to perform.  Resampling is
%                  performed after each transition, inlcuding the last step
% Optional Inputs
%    b_display  (default false) : Print out the mean and std dev of points
%                  after each step
%
%
% Outputs
%   theta       :  Set of samples after the last transition (could
%                  potentially return samples from all iterations but these
%                  will be correlated)
%   log_Z       :  Estimate of the log marginal likelihood
%   ess         :  Effective sample size
%
% TR 24/04/16

if ~exist('b_display','var') || isempty(b_display)
    b_display = false;
end

[n_samples, D] = size(theta_start);
theta_store = NaN(n_samples,n_steps,D);
log_w_store = NaN(n_samples,n_steps);

theta_old = theta_start;

for n=1:n_steps
    theta = q_sample(theta_old);
    theta_store(:,n,:) = theta;
    log_p = p_log_pdf(theta,data);
    assert(~any(isnan(log_p)),'Your p_log_pdf is spitting out NaNs!');
    log_q = q_log_pdf(theta_old,theta);
    assert(~any(isnan(log_q)),'The proposal is spitting out NaNs!');
    
    log_w = log_p - log_q;
    log_w(isnan(log_w) | isinf(log_w)) = -inf;
    log_w_store(:,n) = log_w;
    
    theta = resample_theta(theta,log_w,n_samples);
    theta_old = theta;
end

theta = reshape(theta_store,[],D);
log_w = reshape(log_w_store,[],1);
[theta,log_Z,ess] = resample_theta(theta,log_w,n_samples);

if b_display
    disp(['ess ' num2str(ess)])
    disp(['mean ' num2str(mean(theta)) ' std_dev ' num2str(std(theta))])
end

end

function [theta,log_Z,ess] = resample_theta(theta,log_w,n_samples)
    z_max = max(log_w);
    w = exp(log_w(:)-z_max);
    sum_w = sum(w);
    log_Z = z_max+log(sum_w)-log(numel(w));
    ess = (sum_w.^2)/sum(w.^2);
    
    w = w/sum_w;
    assert(~any(isnan(w)),'At least one of weights is NaN');
    
    edges = min([0;cumsum(w)],1);
    edges(end) = 1;
    % drawsForResample = rand(n_samples,1); Multinomoial resampling
    % Systematic resampling
    drawsForResample = rand/n_samples+(0:(n_samples-1))'/n_samples;
    [~,i_resample] = histc(drawsForResample,edges);
    theta = theta(i_resample,:);
end