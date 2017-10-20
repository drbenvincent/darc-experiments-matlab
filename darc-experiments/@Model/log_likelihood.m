function ll = log_likelihood(obj,theta, DESIGNS_RUN, RESPONSES)
%log_likelihood
% 
% Calculate the likelihood of the data, given the data log(P(data|theta)). 
% This assumes a single binary response is given on each trial.
%
% Inputs
%   theta:	A matrix of particles in paramter space. Each column is one
%					  parameter dimension. Each row corresponds to a particle.
%   data:   A matrix of data. Each row corresponds to a particular trial.
%						The first R-1 rows correspond to the design, the final (Rth)
%						row is the binary response (y)
%
% Outputs
%   ll : Log likelihood of data, for given parameters (theta), 
%        log(P(data|theta)).
%
% Ben Vincent, www.inferenceLab.com, May 2016

% We have no data at the start of the experiment, so the likelihood
% component of the posterior contributes log(0)=-inf.
if isempty(DESIGNS_RUN)
	%ll = log(zeros(size(theta,1),1));
	ll = 0;
	return
end

log_p_choseLater = zeros(size(theta,1),size(DESIGNS_RUN,1));
for n=1:size(DESIGNS_RUN,1)
    log_p_choseLater(:,n) = obj.log_predictive_y(theta,DESIGNS_RUN(n,:));
end

p_choseLater = exp(log_p_choseLater);
p_choseLater(:,~RESPONSES) = 1-p_choseLater(:,~RESPONSES);

p_choseLater = max(min(p_choseLater,1),0); % For numerical stability

% sum over trials (columns)
ll = sum(log(p_choseLater),2);
% 
% % log prob of the observed responses for all theta values
% ll = log(binopdf(...
% 	repmat(RESPONSES', size(p_y_equal_1,1), 1),... % binary responses
% 	ones(size(p_y_equal_1)),... % because we are calculating response==1
% 	p_y_equal_1)); % probability
% 
% % sum over trials
% ll = sum(ll,2);

%% set probability of any sample outside of bounds to zero

assert(~any(isnan(ll)),'ll producing NaNs');

return