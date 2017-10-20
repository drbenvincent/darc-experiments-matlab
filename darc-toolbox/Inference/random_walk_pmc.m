function [theta, log_Z] = random_walk_pmc(p_log_pdf,theta_start,n_steps,step_type,scale_walk_factor,nu,b_display, data)
%random_walk_pmc
%
% Automatically sets some of the required parameters for pmc using a random
% walk based proposal distribution.  The calls pmc to return a new set of
% particles representing the posterior and the estimated marginal
% likelihood.  Proposal is an independent student t in each direction or
% gaussian in each direction depending on choice of step_type option
%
% Inputs
%    p_log_pdf  :  Anonymous function giving the log pdf of the target
%                  distribution p (i.e. the posterior).  Need not be 
%                  normalized.  Should take a
%                  single matrix as arguments where different rows are
%                  different samples and different columns are different
%                  dimensions
%    theta_start : A matrix of starting points for the sampler
%    n_steps    :  Number of transitions to perform.  Resampling is
%                  performed after each transition, inlcuding the last step
%
% Optional inputs
%   step_type ('normal' (default) or 'student_t') : Type of distribution to
%                  use for the proposal.  The student_t is a little more
%                  robust but is slower to evaluate.
%   scale_walk_factor (scalar) : Proposal variance scaled is by this.  For
%                  student t the default is 0.5, for normal the default is
%                  1.
%   nu (default 5) :  Student t parameter, see wikipedia (only used if
%                  step_type == 'student_t')
%   b_display  (default false) : Print out the mean and std dev of points
%                  after each step
% Outputs
%   theta       :  Set of samples after the last transition (could
%                  potentially return samples from all iterations but these
%                  will be correlated)
%   log_Z       :  Estimate of the log marginal likelihood
%
% TR 05/05/16

if ~exist('step_type','var') || isempty(step_type)
    step_type = 'normal';
end

if ~exist('data','var')
    data = [];
end

assert(any(strcmpi(step_type,{'normal','student_t'})),'Step type must be ''normal'' or ''student_t''');

if ~exist('scale_walk_factor','var') || isempty(scale_walk_factor)
    if strcmpi(step_type,'normal')
        scale_walk_factor = 2;
    else
        scale_walk_factor = 2;
    end
end

if ~exist('nu','var') || isempty(nu)
    nu = 5;
end

if ~exist('b_display','var') || isempty(b_display)
    b_display = false;
end

scale_walk = scale_walk_factor.*std(theta_start,[],1);

if strcmpi(step_type,'normal')
    q_log_pdf = @(x1,x2) sum(log(normpdf(bsxfun(@rdivide,(x1-x2),scale_walk),0,1)),2);
    q_sample = @(x_old) bsxfun(@times,randn(size(x_old)),scale_walk)+x_old;
else
    q_log_pdf = @(x1,x2) sum(log(tpdf(bsxfun(@rdivide,(x1-x2),scale_walk),nu)),2);
    q_sample = @(x_old) bsxfun(@times,trnd(nu,size(x_old)),scale_walk)+x_old;
end

[theta, log_Z] = pmc(p_log_pdf,q_log_pdf,q_sample,theta_start,n_steps,b_display, data);