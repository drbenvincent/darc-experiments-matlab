clear all
close all

f_true = @(d) d.^3-d;

% Prior
log_prior_pdf = @(theta) sum(log(normpdf(theta,zeros(1,3),ones(1,3))),2);
out_noise = 0.25;
f_quad = @(theta,d) theta(:,1).*d.^2+theta(:,2).*d+theta(:,3);
log_likelihood = @(theta,d,y) log(normpdf(y,f_quad(theta,d),out_noise));
predict_sampler = @(theta,d) randn(size(theta,1),1).*out_noise+f_quad(theta,d);
true_out_sampler = @(d) f_true(d)+out_noise*randn;
p_log_pdf = @(theta, data) log_prior_pdf(theta)+sum(log_likelihood(theta, data(1,:), data(2,:)),2);

N = 1.5e5;
n_iter = 6;
n_designs = 21;
n_pmc_steps = 100;
pmc_step_size = 1;

allowable_designs = linspace(-2,2,n_designs);
designs = NaN(n_iter,1);
outputs = NaN(n_iter,1);
EIGs = NaN(n_iter,n_designs);
thetas = randn(N,3);

for t=1:n_iter
    [designs(t),EIGs(t,:)] = choose_next_design(allowable_designs,thetas,log_likelihood,predict_sampler);
    outputs(t) = true_out_sampler(designs(t));
    data = [designs(1:t)';outputs(1:t)'];
    thetas = random_walk_pmc(p_log_pdf,thetas,n_pmc_steps,'student_t',pmc_step_size,[],true, data);
    disp(['t=' num2str(t)])
end

figure; 
for n=1:n_iter
subplot(ceil(n_iter/5),5,n); 
plot(allowable_designs,EIGs(n,:));
end

function [design,EIGs] = choose_next_design(allowable_designs,thetas,log_likelihood,predict_sampler)

EIGs = NaN(numel(allowable_designs),1);

for n=1:numel(allowable_designs)
    EIGs(n) = estimate_eig(thetas,log_likelihood,predict_sampler,allowable_designs(n));
end

[~,id] = max(EIGs);

design = allowable_designs(id);

end

function EIG = estimate_eig(thetas,log_likelihood,predict_sampler,d)

M = 1000;
N = size(thetas,1);
M = min(M,N-2);
ys = predict_sampler(thetas,d);
perm_ids = randperm(N);
ys = ys(perm_ids,:);
thetas = thetas(perm_ids,:);

V1 = mean(log_likelihood(thetas,d*ones(size(ys)),ys));

inner_ids = mod((0:M-1)'+(1:N),N)+1;
outer_ids = repmat(1:N,M,1);
liks = exp(log_likelihood(thetas(inner_ids(:),:),d,ys(outer_ids(:))));
% inner_ests = NaN(size(ys,1),1);
inner_ests = mean(reshape(liks,M,N),1)';
% for m=1:numel(inner_ests)
%     inner_ests(m) = mean(exp(log_likelihood(thetas(mod(m:m+M-1,N)+1,:),d,ys(m))));
% end
V2 = mean(log(inner_ests));
EIG = V1-V2;
end