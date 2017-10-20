function theta = point_estimate_theta(obj,thetas,method,data,prop_samples_MAP)
%theta_bar = point_estimate_theta(obj,theta,method,data)
%
% Calculates a point estimate for theta given a set of samples and a
% method.  Currently supported methods are 'median', 'mean', 'random',
% and 'MAP'.  The data only needs to be provided for the MAP case as this
% recalculates the probability.  Different samples should be different rows
% of theta.  Default method is 'median'.
%
% Tom Rainforth 21/06/17

if ~exist('method','var')
    method = 'median';
end

switch method
    case 'median'
        % This is reasonable provided that the samples form a convex set.
        % If they do not (e.g. imagine data distributed as a horseshoe)
        % the both the median and the mean may be unrepresentative samples.
        theta = median(thetas,1);
    case 'mean'
        % The mean can be less stable that the median and is affected by
        % input warping (e.g. using k or log k) in ways the median isn't.
        % However, if the output dependency is roughly linearly dependent
        % on the parameters, then it will account for skew better then the
        % median
        theta = mean(thetas,1); 
    case 'random'
        theta = thetas(randi(size(thetas,1)),:);
    case 'MAP'
        assert(logical(exist('data','var')),'Need to provide data for MAP case')
        % Its a bit of a hack but for computational reasons, we currently
        % by default only use 1/10th of the samples (or 100 samples if this
        % is larger) to do the MAP estimate.  This can be changed by the
        % otherwise uncommented option prop_samples_MAP        
        if ~exist('prop_samples_MAP','var')
            prop_samples_MAP = 0.1;
        end
        ns = min(size(thetas,1),max(size(thetas,1)*prop_samples_MAP,100));
        is = datasample(1:size(thetas,1),ns);
        ps = obj.p_log_pdf(thetas(is,:),data)+(1e-10)*rand(ns,1); % Add small noise so don't pathologically 
                                                                 % choose the sample value when equal prob
        [~,ibest] = max(ps);
        theta = thetas(is(ibest),:);        
    otherwise
        error('Invalid point estimate type')
end