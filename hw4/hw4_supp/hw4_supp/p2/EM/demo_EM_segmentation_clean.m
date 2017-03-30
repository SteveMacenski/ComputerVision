function demo_EM_segmentation_clean(im, K)
% demo_EM_segmentation(im, K)
% Estimates the mixture of K gaussians from the intensity image
% virtually same as demo_EM_segmentation(im, K), but without display code

x = im(:);
N = numel(x);
minsigma = std(x)/numel(x); % prevent component from getting 0 variance

% Initialize GMM parameters
prior = zeros(K, 1);
mu = zeros(K, 1); 
sigma = zeros(K, 1);
prior(:) = 1/K;
minx = min(x); 
maxx = max(x);
for k = 1:K
    mu(k) = (0.1+0.8*rand(1))*(maxx-minx) + minx;
    sigma(k) = (1/K)*std(x); 
end

% Initialize P(component_i | x_i) (initial values not important)
pm = ones(N, K);
oldpm = zeros(N, K);

maxiter = 200;
niter = 0;
% EM algorithm: loop until convergence
while (mean(abs(pm(:)-oldpm(:)))>0.001) && (niter < maxiter) 
  
  niter = niter+1;  
  oldpm = pm;
    
  % estimate probability that each data point belongs to each component
  for k = 1:K
      pm(:, k) = prior(k)*normpdf(x, mu(k), sigma(k));
  end
  pm = pm ./ repmat(sum(pm, 2), [1 K]);

  % compute maximum likelihood parameters for expected components
  for k = 1:K
      prior(k) = sum(pm(:, k))/N;
      mu(k) = sum(pm(:, k).*x) / sum(pm(:, k));
      sigma(k) = sqrt( sum(pm(:, k).*(x - mu(k)).^2) / sum(pm(:, k)));
      sigma(k) = max(sigma(k), minsigma); % prevent variance from going to 0
  end

end

