function p_log_pdf = p_log_pdf(obj, theta, data)

p_log_pdf = obj.log_prior_pdf(theta);

if ~isempty(data)
    b_finite = ~isinf(p_log_pdf);
    p_log_pdf(b_finite) = p_log_pdf(b_finite) + obj.log_likelihood(theta(b_finite,:),data(:,1:end-1),data(:,end));
end

end