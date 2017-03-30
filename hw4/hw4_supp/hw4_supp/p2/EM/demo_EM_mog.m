function demo_EM_mog

% set ground truth
mu_gt = [0 1];
sigma_gt = [2 0.5];
prior_gt = [0.5 0.5]; %note, this is fixed by data
N = round(100*prior_gt);
K = 10; % number of components to estimate

x = randn(N(1), 1)*sigma_gt(1)+mu_gt(1);
x = [x ; randn(N(2), 1)*sigma_gt(2)+mu_gt(2)];


% display ground truth
xrange = -10:0.01:10;
figure(1), hold off, plot(xrange, normpdf(xrange, mu_gt(1), sigma_gt(1))*0.5, 'b', 'linewidth', 2), hold on;
plot(xrange, normpdf(xrange, mu_gt(2), sigma_gt(2))*0.5, 'g', 'linewidth', 2)
pdata = 0;
for k = 1:2
    pdata = pdata + prior_gt(k)*normpdf(x, mu_gt(k), sigma_gt(k));
end
disp(['Mean Log P(data) for Ground Truth: ', num2str(mean(log(pdata)))])

% solve mixture of gaussian
[mu, sigma, prior] = EM_gaussian(x, K);

% display final solution
figure(4), hold off, plot(xrange, normpdf(xrange, mu_gt(1), sigma_gt(1))*prior_gt(1), 'b', 'linewidth', 2), hold on;
plot(xrange, normpdf(xrange, mu_gt(2), sigma_gt(2))*prior_gt(2), 'g', 'linewidth', 2);
colors = 'bgrcyk'; hold on;
for k = 1:numel(mu)
    plot(xrange, prior(k)*normpdf(xrange, mu(k), sigma(k)), [colors(mod(k-1,6)+1) '--'], 'linewidth', 2), 
end

% compute overall probability for ground truth and mixture
pgt = zeros(size(xrange));
for k = 1:numel(mu_gt)
  pgt = pgt + normpdf(xrange, mu_gt(k), sigma_gt(k))*prior_gt(k);
end
pest = zeros(size(xrange));
for k = 1:numel(mu)
  pest = pest + normpdf(xrange, mu(k), sigma(k))*prior(k);
end
figure(5), hold off, plot(xrange, pgt, 'g', 'linewidth', 3);
hold on, plot(xrange, pest, '-k', 'linewidth', 1);

function [mu, sigma, prior] = EM_gaussian(x, K)

x = x(:);
N = numel(x);

% Random Initialization
mu = zeros(K, 1);
sigma = zeros(K, 1);
minx = min(x); maxx = max(x);
for k = 1:K
    mu(k) = (0.1+0.8*rand(1))*(maxx-minx) + minx;
    sigma(k) = (rand(1)*0.9+0.1)*std(x);
end
prior = zeros(K, 1);
prior(:) = 1/K;

pm = 1/K*ones(N, K);
oldpm = zeros(N, K);
logp = [];
while any(abs(pm-oldpm)>0.001) % convergence test
    
    oldpm = pm;
  
    % display current estimates
    xrange = minx:0.01:maxx;    
    leg = {};
    figure(2), hold off,
    colors = 'bgrcyk';
    for k = 1:K
        plot(xrange, prior(k)*normpdf(xrange, mu(k), sigma(k)), colors(mod(k-1,6)+1), 'linewidth', 2), 
        hold on;
        leg{k} = sprintf('{pi=%.2f, mu=%.2f, sigma=%.2f}', prior(k), mu(k), sigma(k));
    end
    legend(leg);
    
    % estimate probability that each data point belongs to each component
    for k = 1:K
        pm(:, k) = prior(k)*normpdf(x, mu(k), sigma(k));
    end
    pm = pm ./ repmat(sum(pm, 2), [1 K]);
    
    % compute maximum likelihood parameters for expected densities
    for k = 1:K
        prior(k) = sum(pm(:, k))/N;
        mu(k) = sum(pm(:, k).*x) / sum(pm(:, k));
        sigma(k) = sqrt( sum(pm(:, k).*(x - mu(k)).^2)/sum(pm(:, k)))+eps;
    end
    

    % display likelihoods
    pdata = 0;
    for k = 1:K
        pdata = pdata + prior(k)*normpdf(x, mu(k), sigma(k));
    end
    logp(end+1) = mean(log(pdata));

    figure(3), hold off, plot(logp)
    legend(sprintf('Mean Log P(data) = %.4f', logp(end)))
    
    %pause; %% XXXXX
end
