% An example / test script for running the pmc

% Prior
mu_prior = 0;
sig_prior = 0.1;
% Prior is theta ~ norm(mu_prior,sig_prior)
log_prior_pdf = @(theta) log(normpdf(theta,mu_prior,sig_prior)); % Would be better to acutally directly code the log normal for numerical stability

data = [0.4, 0.6, 0.5, 0.4];

lik_sig = 0.1;
% Note will need to accept an array where different rows are the different
% particles, hence the need for the bsxfun
% Likelihood = p(data|theta) = prod_i Normal(data_i ; theta, lik_sig)
log_likelihood = @(theta,data) sum(log(normpdf(bsxfun(@minus,theta,data),0,lik_sig)),2); % Would be better to acutally directly code the log normal for numerical stability

% This gives an unnormalized posterior p(data|theta)p(theta)
p_log_pdf = @(theta, data) log_prior_pdf(theta)+log_likelihood(theta, data);

% Random start points
n_points = 5e5;
theta_start = randn(n_points,1)*2+0.4; % Should work for any start.  This is deliberately not the truth

% Run pmc
n_steps = 5;
[theta, log_Z] = random_walk_pmc(p_log_pdf,theta_start,n_steps,'normal',[],[],true, data);

% Show results
figure;
hist(theta,100);

mu_found = mean(theta,1);
sig_found = std(theta);

true_mean = 0.38; % HARD CODED ATM!
true_std_dev = 0.0447;

disp(['Gaussian example true mean ' num2str(true_mean) ' found mean ' num2str(mu_found)]);
disp(['Gaussian example true std dev ' num2str(true_std_dev) ' found std dev ' num2str(sig_found)]);

%%

% Alternative target

% Target
mu_1 = 1; sig_1 = 0.2;
shape_2 = 2; scale_2 = 2;
p_log_pdf = @(x,data) log(normpdf(x(:,1),mu_1,sig_1))+log(gampdf(x(:,2),shape_2,scale_2)); % For numerical stability would be better to use something that directly calculates the log

% Random start points
n_points = 5e5;
theta_start = abs(randn(n_points,2)*2+0.4); % Should work for any start.  This is deliberately not the truth

% Run pmc
n_steps = 5;
[theta, log_Z] = random_walk_pmc(p_log_pdf,theta_start,n_steps,'student_t');

% Show results
figure;
hist3(theta,[25,25]);

mu_found = mean(theta,1);
cov_found = cov(theta);

disp(['Gamma-Gaussian example true mean ' num2str([mu_1 shape_2*scale_2]) ' found mean ' num2str(mu_found)]);
disp('Gamma-Gaussian true cov ')
disp([sig_1^2 0; 0 shape_2*scale_2^2])
disp(' found cov ' );
disp(cov_found)

