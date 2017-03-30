function showGMM(im, K, poly)

Nrestart = 5;
[L, a, b] = rgb2lab(im);

[imh, imw] = size(L);

rp = randperm(numel(L));
rp = rp(1:min(10000, numel(L))); % sample 10K points
data = cat(2, L(:), a(:), b(:));
gmm = gmdistribution.fit(data(rp, :), K, ...
  'start', 'randsample', 'Replicates', Nrestart, 'CovType', 'full', ...
  'Regularize', std(L(:))/numel(rp));

p = posterior(gmm, data);

figure(1), hold off, imshow(im);
figure(2), clf; hold off;
for k = 1:K
  subplot(ceil(sqrt(K)), round(sqrt(K)), k), imagesc(reshape(p(:, k), [imh imw])), axis image; axis off
end

