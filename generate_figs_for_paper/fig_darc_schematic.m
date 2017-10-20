% fig_darc_schematic
% Create the basic structure of the figure to demonstrate the approaches:
% - Expected Utility Theory
% - Prospect Theory
% - Discounting

f = figure(1);
clf
h = layout([1, 2, 3; 4 5 6; 7 8 9]);


reward = linspace(-10,10,100);
probability = linspace(0,1,1000);
delays = linspace(0,365, 3650);
odds = (1-probability)./probability;


%% EUT

% linear utility
subplot(h(1))

p = plot(reward, reward, 'k-','Linewidth',2);

h(1).XAxisLocation = 'origin';
h(1).YAxisLocation = 'origin';
xlabel('$R$', 'interpreter', 'latex')
ylabel('$u(R)$', 'interpreter', 'latex')
axis equal
axis square
box off


% linear probability
subplot(h(2))

p = plot(probability, probability, 'k-','Linewidth',2);
xlabel('$P$', 'interpreter', 'latex')
ylabel('$\pi (P)$', 'interpreter', 'latex')
axis equal
box off
axis([0 1 0 1])


% exponential discounting
subplot(h(3))
plot(delays, exp(-0.005.*delays), 'k-','Linewidth',2);
xlabel('$D$', 'interpreter', 'latex')
ylabel('$d(D)$', 'interpreter', 'latex')
xlim([0, 365])
box off
axis square





%% prospect theory

% value function
subplot(h(4))

alpha = 0.6;
beta = 0.6;
loss = 1.5;
p = plot(reward, pt_util_function(reward, alpha, beta, loss),...
    'k-','Linewidth',2);
xlabel('$R$', 'interpreter', 'latex')
ylabel('$u(R)$', 'interpreter', 'latex')
axis equal
axis square
box off
h(4).XAxisLocation = 'origin';
h(4).YAxisLocation = 'origin';

% prospect theory weighting function
% linear probability
subplot(h(5))

delta = 0.6;
gamma = 0.4;
wf = @(p) (delta.*p.^gamma) ./ ((delta.*p.^gamma) + (1-p).^gamma);

p = plot(probability, wf(probability), 'k-','Linewidth',2);
hold on
plot([0 1],[0 1], 'k-')
xlabel('$P$', 'interpreter', 'latex')
ylabel('$\pi (P)$', 'interpreter', 'latex')
axis equal
axis square
box off
axis([0 1 0 1])



% no time discounting
subplot(h(6))
plot(delays, ones(size(delays)), 'k-','Linewidth',2);
xlabel('$D$', 'interpreter', 'latex')
ylabel('$d(D)$', 'interpreter', 'latex')
xlim([0, 365])
ylim([0 1.1])
box off
axis square


%% Discounting approaches

% linear utility function
subplot(h(7))

p = plot(reward, reward, 'k-','Linewidth',2);
xlabel('$R$', 'interpreter', 'latex')
ylabel('$u(R)$', 'interpreter', 'latex')
axis equal
axis square
box off
h(6).XAxisLocation = 'origin';
h(6).YAxisLocation = 'origin';

% hyperbolic discounting of odds
subplot(h(8))
plot(odds, 1./(1+1.*odds), 'k-','Linewidth',2);
xlabel('$ odds = \frac{1-P}{P}$', 'interpreter', 'latex')
ylabel('$ \pi(\frac{1-P}{P}) $', 'interpreter', 'latex')
xlim([0, 10])
axis square
box off
addTextToFigure('BL',' risk averse', 12)
addTextToFigure('TR','risk seeking', 12)

% hyperbolic discounting of delay
subplot(h(9))
plot(delays, 1./(1+exp(-3).*delays), 'k-','Linewidth',2);
xlabel('$D$', 'interpreter', 'latex')
ylabel('$d(D)$', 'interpreter', 'latex')
xlim([0, 365])
axis square
box off


%% Export
set(gcf,'Position',[10 10 900 700])
savefig('figs/darc_schematic_raw')
export_fig('figs/darc_schematic_raw', '-pdf')


function u = pt_util_function(reward, alpha, beta, loss)
u(reward>=0)    = reward(reward>=0).^alpha;
u(reward<0)     = -loss.*((-reward(reward<0)).^beta);
end
