function [chosen_design, estimated_utilities, estimated_unpenalized_utilities] = ...
            discrete_smc_search_binary_output(log_predictive,candidate_designs,...
            theta_samples,previous_designs,penalty_function,...
            n_particles,n_steps,gamma,output_type_force,pD_min_prop)
%discrete_smc_search_binary_output
%
% function [chosen_design, estimated_utilities] = ...
%            discrete_smc_search_binary_output(log_predictive,
%               candidate_designs,theta_samples,n_particles,n_steps,...
%               gamma,output_type_force)
%
% Performs a smc search algorithm similar to given in Amzal et al for 
% calculating the best design from a discrete set according to an entropy 
% reduction criterion.  Presumes that the output of the experiment is binary.
%
% Note this in itself a unique algorithm that has not occured directly in
% the literature before.
%
% Inputs :
%   log_predictive = Anonymous function of the form f(theta,D) that returns
%                    log(p(Y==1|theta,D)), i.e. the predictive distribution
%                    of y for a bernoulli given a particular theta and D.  
%                    MUST BE CORRECTLY NORMALIZED
%   candidate_designs (nD x dD array) = Array of all the valid designs.
%                                       TODO: for higher dimensions then
%                                       this will be impractical.  However,
%                                       as this will most likely require a
%                                       seperate optimization algorithm
%                                       anyway I omit it for now.
%   theta_samples (nT x dT array) = Set of unweighted samples representing
%                                   the posterior over parameters.  Note
%                                   that can always convert a weighted set
%                                   of particles to an unweighted set by
%                                   sampling with replacement (see
%                                   resampling code in pmc).  Note the
%                                   speed is proportional to the number of
%                                   theta_samples therefore if things are
%                                   going to slowly then may be advisable
%                                   to use less samples.
%
% Optional inputs :
%   previous_designs (? x dD array) = Array of previous designs.  Will be
%                                     used by penalty_function.
%                                     Empty by default
%   penalty_function = Anonymous function that takes in previous
%                                 designs (second input) and candidate 
%                                 designs (first input) and returns
%                                 a nDx1 array of penalty factors for how
%                                 close that design is to previous points.
%                                 By default, no penalty is applied.
%   n_particles (scalar <= nT) = Number of theta samples to use at each
%                      iteration (default = nT).  Must not be
%                      more than the number of samples provided.  If less
%                      then the order of the samples is randomly permuted
%                      and the data then cycled through.  Default nT
%   n_steps (scalar) = Number of annealing steps to run the optimizer for.
%                      Default 50;
%   gamma (anonymous function with integer input) = Annealing schedule for 
%           the  optimization.  At step n+1 we sample designs in proportion 
%           to U.^gamma(n).  Thus the larger gamma(n) is the more 
%           aggressively the computational reasources concentrate on the 
%           what the maximum this far is expected to be.  Default is that
%           gamma(n) = n;  Note that can also be a vector of length
%           n_steps-1 as when called with integer inputs this operates as
%           in same manner as an anonymous function.
%  output_type_force ('none' (default) | 'true' | 'false')
%           = Ther can be apathology where the model asks almost exlusively 
%             questions that have the same answer due to the model 
%             misspecification causing over confidence.  We might therefore
%             wish to ask the question that maximizes the entropy reduction
%             subject to for example p(Y=1|D) > 0.5 ('true') or 
%             p(Y=0|D) < 0.5 ('false').  In other words we might wish try 
%             to force an artificial balancing of the number of questions 
%             which get answered true or false to make sure we have 
%             reperesentative data.  This seemed to help in practise with 
%             my original implementation.
%  pD_min_prop real between 0 and 1(default = 1/100)
%           = Minimum value of the probability of sampling a design as a
%             proportion of the average, i.e.   
%               pD_min = pD_min_prop/nD where nD is number of designs
%             This is done before the renormalizing so the true pD_min can
%             is very slightly smaller.  Note that the result of this is 
%             that on average pD_min_prop of the computational resources
%             are randomly allocated.  This is necessary to ensure
%             convergence, but we will usually have pD_min_prop set to a
%             small value.
%       
%
% Outputs :
%   chosen_design (1 x dD row vector) = The chosen "optimal" design
%   estimated_utilities (nD x 1 column vector) = 
%            The estimated value of the utility for each design including
%            the penalty factor.  Accuracy will be more accurate in
%            the regions near the maximum
%   estimated_unpenalized_utilities (nD x 1 column vector) = 
%            As above without the penalty factors
%
% TODO: Also write the case for non binary outputs (this will need to be
% written with some noticeable differences)
%
% TODO: Allow for working in higher dimensions by allowing MCMC transitions
% between designs rather than global selection.
%
% TODO: Change to incorporate uncertainty in the estimates - we should be
% sampling from some sort of upper confidence bound or probability of the
% point being the maximum rather than an annealed version of the mean
% estimate.
%
% TR 06/05/16

assert(isa(log_predictive,'function_handle'),...
	'log_predictive must be a function handle')

nD = size(candidate_designs,1);
nT = size(theta_samples,1);

U = (1/nD)*ones(nD,1); % This will keep track of "target" function for the
                        % the optimization at each of the candidate points.
n_times_sampled = zeros(nD,1); % Tracks number of times a design was sampled
p_y_given_D = 0.5*ones(nD,1); % Tracks a running estimate of p(y | D)

if ~exist('previous_designs','var')
    previous_designs = [];
end

if ~exist('penalty_function','var')
    penalty_function = [];
end

if ~exist('n_particles','var') || isempty(n_particles)
    n_particles = nT;
else
    assert(n_particles<=nT,'n_particles must be less than or equal to nT');
end

if ~exist('n_steps','var') || isempty(n_steps)
    n_steps = 50;
end
         
if ~exist('gamma','var') || isempty(gamma)
    gamma = 0:(n_steps-1);
end

if ~exist('output_type_force','var') || isempty(output_type_force)
    output_type_force = 'none';
end

if ~exist('pD_min_prop','var') || isempty(pD_min_prop)
    pD_min_prop = 1/100;
end

pD_min = pD_min_prop/nD;

if ~isempty(previous_designs) && ~isempty(penalty_function)
    penalty_factors = penalty_function(candidate_designs,previous_designs);
else
    penalty_factors = ones(nD,1);
end

% Randomly permute the samples so that if not using all of them then there
% is not a bias originating from the ordering
theta_samples = theta_samples(randperm(nT),:);
theta_position_counter = 0;

for nSam=1:n_steps
    % First sample experiments to go with parameter samples with probability
    % proportional to pD.^gamma(nSam).  Each sample will correspond to a
    % sample of the parameters (note we expect nT>>nD such that each design
    % has a number of samples associated with it).
    
    if sum(U)==0
        warning('No design helpful, off the edge of the design space!');
        chosen_design = candidate_designs(randi(nD),:);
        estimated_utilities = U;
        return
    end
     
    U_bar = U/sum(U); % To guard against underflow    
    pD = U_bar.^gamma(nSam);
    pD = pD/sum(pD);
    pD = max(pD,pD_min);
    pD = pD/sum(pD);
    iSamples = datasample((1:nD)',n_particles,'Replace',true,'Weights',pD);
    D_samples = candidate_designs(iSamples,:);
    
    % This is only needed for checks on sizes
    max_i_sampled = max(iSamples);
    
    % Number of times a design was sampled this ireations
    n_times_sampled_iter = zeros(nD,1); % Placeholder as accumarray output size can vary
    n_times_sampled_iter(1:max_i_sampled) = accumarray(iSamples,ones(numel(iSamples),1));
    
    % Select the theta_samples that will be used this iteration
    theta_end_position = theta_position_counter+n_particles;
    if theta_end_position<nT
        theta_iter = theta_samples((theta_position_counter+1):theta_end_position,:);
    else
        theta_iter = theta_samples([1:mod(theta_end_position,nT),(theta_position_counter+1):end],:);
    end
    theta_position_counter = mod(theta_end_position,nT);
    
    % Call one step predictive function for each design-parameter pair, 
    % note that this is already normalized so pnotY = 1-pY.  
    log_p_y_given_theta_and_D = log_predictive(theta_iter,D_samples);
    p_y_given_theta_and_D = exp(log_p_y_given_theta_and_D);
    
    % Calculated p(Y|D) by marginalizing over theta
    p_y_given_D_iter_times_n_samples = zeros(nD,1);  % Placeholder as accumarray output size can vary
    p_y_given_D_iter_times_n_samples(1:max_i_sampled) = accumarray(iSamples,p_y_given_theta_and_D);
    % Update the running estimate from all iterations
    p_y_given_D = (p_y_given_D.*n_times_sampled+p_y_given_D_iter_times_n_samples)./(n_times_sampled+n_times_sampled_iter);
    p_y_given_D(isnan(p_y_given_D)) = 0.5; % Anything with no examples of has probability 0.5
    
    % TODO think about whether there are implications that different
    % iterations have different p_y_given_D estimates - should we have some
    % sort of burn in period?
    
    % The utility of a step is the mutual information between
    % the parameter and the observation.  Note this is equal
    % to the expected gain in Shannon information from prior
    % to posterior for a single question
    % First marginalize over y
    U_theta = p_y_given_theta_and_D.*(log_p_y_given_theta_and_D-log(p_y_given_D(iSamples)))+...
                           (1-p_y_given_theta_and_D).*(log(1-p_y_given_theta_and_D)-log(1-p_y_given_D(iSamples)));
    U_theta(isnan(U_theta)) = 0; % Anything with numerical instability has no utility
                                 % as the instability ocurs because we are
                                 % certain of the result
    U_theta = max(U_theta,0); % Any negatives are just numerical instability
                       
    % Final utility from iterations also marginalized out over theta
    U_iter_times_n_samples = zeros(nD,1); % Need to start with placeholder as accumarray can be undersized
    U_iter_times_n_samples(1:max_i_sampled) = (accumarray(iSamples,U_theta)); 
    % TODO: calculate more than just the mean to calculate probability the point is the maximum
   
    % Apply the penalty factors
    U_iter_times_n_samples = U_iter_times_n_samples.*penalty_factors;

    % Update the running estimate of U for each point
    b_some_samples = (n_times_sampled+n_times_sampled_iter)>0;
    U = (U.*n_times_sampled+U_iter_times_n_samples)./(n_times_sampled+n_times_sampled_iter);
    U(~b_some_samples) = 1/nD;
    U(U<0) = 0; % guard against numerical error
            
    % Update the counts of times the design was sampled
    n_times_sampled = n_times_sampled+n_times_sampled_iter;
end

switch output_type_force
% Allow for choosing a design conditioned on expecting the answer to be
% either true or false.
% TODO: We could refine this by instead allowing a function of p_y_given_D
%       to estimate viability (for example it might say only choose cases 
%       were we expect 0.4<p(y|D)<0.5
    case 'true'
        if max(p_y_given_D)>=0.5
            U(p_y_given_D<0.5) = 0;
        end
    case 'false'
        if min(p_y_given_D)<=0.5
            U(p_y_given_D>0.5) = 0;
        end
    otherwise
        % case 'none'
        % All options are valid
end

% Choose the design for which pD is maximal
estimated_utilities = U;
estimated_unpenalized_utilities = U./penalty_factors;
[~,iTake] = max(estimated_utilities);
chosen_design = candidate_designs(iTake,:);