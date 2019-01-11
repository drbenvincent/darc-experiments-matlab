function penalty_factors = default_penalty_function(convert_to_ranks,candidate_designs,previous_designs,base_sigma,lambda)

[nD,dD] = size(candidate_designs);

if isempty(previous_designs)
    penalty_factors = ones(nD,1);
    return
end

if ~exist('base_sigma','var')
    base_sigma = 1;
end

sigma = base_sigma/size(previous_designs,1);

if ~exist('lambda','var')
    % Deliberately random to encourage diversity in our choices
    lambda = gamrnd(2,1.5);
end

candidate_designs = convert_to_ranks(candidate_designs);
previous_designs = convert_to_ranks(previous_designs);

p = ones(nD,1);

for d=1:dD
    p = p.*ksdensity(previous_designs(:,d),candidate_designs(:,d),'Bandwidth',sigma);
end

p = p/max(p);

penalty_factors = 1./(1+lambda*p);

end