function [theta, log_Z] = pmc(p_log_pdf,q_log_pdf,q_sample,theta_start,n_steps,b_display, data)
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
%
% TR 24/04/16

if ~exist('b_display','var') || isempty(b_display)
    b_display = false;
end

theta_old = theta_start;
log_Z_steps = NaN(n_steps,1);

for n=1:n_steps
    theta = q_sample(theta_old);
    log_p = p_log_pdf(theta,data);
    assert(~any(isnan(log_p)),'Your p_log_pdf is spitting out NaNs!');
    log_q = q_log_pdf(theta_old,theta);
    assert(~any(isnan(log_q)),'The proposal is spitting out NaNs!');
    log_w = log_p - log_q;
    log_w(isnan(log_w) | isinf(log_w)) = -inf;
    z_max = max(log_w);
    w = exp(log_w(:)-z_max);
    sum_w = sum(w);
    w = w/sum(w);
    assert(~any(isnan(w)),'At least one of weights is NaN');
    edges = min([0;cumsum(w)],1);
    edges(end) = 1;
    drawsForResample = rand(size(w,1),1);
    [~,i_resample] = histc(drawsForResample,edges);
    log_Z_steps(n) = z_max+log(sum_w)-log(numel(w));
    theta = theta(i_resample,:);
    theta_old = theta;
    if b_display
        disp(['mean ' num2str(mean(theta)) ' std_dev ' num2str(std(theta))])
    end
end

log_Z_steps_max = max(log_Z_steps);
Zs = exp(log_Z_steps-log_Z_steps_max);
log_Z = log_Z_steps_max+log(sum(Zs))-log(numel(log_Z_steps_max));

end