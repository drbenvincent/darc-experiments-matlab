function logp = log_prior_pdf(obj,theta) 
%log_prior_pdf
%
% Calculate our prior beliefs over particles in parameter space,
% log(P(theta))
%
% Inputs
%   theta:	See unpackTheta
%
% `Outputs
%	logp:	A column vector of prior beliefs in particles in parameter space
%           P(theta).
%
% Ben Vincent, Tom Rainforth, www.inferenceLab.com, May 2016

% Adds all the required variables to the workspace
alpha = []; % Not really sure why but this needs predeclaring as its a pre-existing function
obj.unpackTheta(theta);
% TODO:^^^^ I can do alternative code for this unpackTheta. This might
% negate the need for the `eval` below

% evaluate log prior probability of data
param_names = obj.params;
for n = 1:numel(param_names)
    % note: the eval allows access to the variable names (eg `logk`,
    % `alpha` etc)
    logp(:,n) = log(obj.priors.(param_names{n}).pdf( eval(param_names{n}) ));
end

% sum log probs over columns
logp = sum(logp,2);

% error checking
logp(isnan(logp)) = -inf;

end
