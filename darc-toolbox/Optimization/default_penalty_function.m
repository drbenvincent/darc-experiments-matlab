function penalty_factors = default_penalty_function(convert_to_ranks,...
            candidate_designs,previous_designs,base_sigma,lambda)
               
if ~exist('base_sigma','var')
    base_sigma = 1;
end

if ~exist('lambda','var')
    lambda = 2;
end

[nD,dD] = size(candidate_designs);
nD_prev = size(previous_designs,1);

if isempty(previous_designs)
    % If there are no previous designs, we shouldn't apply any factors
    penalty_factors = ones(nD,1);
    return
end

% To keep problem self similarity, we apply the kernel in the space of
% quantiles.  Namely, we convert each design variable to a quantile in the
% set of allowed values for that variable, with the minimum and maximum
% taken to be 0 and 1 respectively.
candidate_designs = convert_to_ranks(candidate_designs);
previous_designs = convert_to_ranks(previous_designs);

% Though will be eliminated later, this is useful for doing the rescaling
% of p without having to write everything twice.
candidate_designs = [candidate_designs;previous_designs];

% Calculate density of each candidate point under a Gaussian distribution
% centered on each previous design.
differences = candidate_designs-reshape(previous_designs',[1,dD,nD_prev]);
sigma = base_sigma/size(previous_designs,1); % Reduce standard deviation as we get more designs
if isscalar(sigma)
    scaled_distances_squared = squeeze(sum((differences/sigma).^2,2));
    p = exp(-0.5*scaled_distances_squared);
else 
    % base_sigma should be a vector for each dimension
    scaled_distances_squared = squeeze(sum((differences.*(1./reshape(sigma,1,[]))).^2,2));
    p = exp(-0.5*scaled_distances_squared);
end
% Take the mean across previous design points to give the kernel density
% estimate
p = mean(p,2);

p = p/max(p); % Rescale so all p are between 0 and 1
p = p(1:nD); % Remove previous designs

% Calculate final penalty factors
penalty_factors = 1./(1+lambda*p);

end