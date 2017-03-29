% Steve Macenski (c) 2017
% SLIC (Achanta et al. PAMI 2012) implementation
clear all; clc;

% reading in image
im = im2double(imread('./lion.jpg'));

%% Part b: produce plots of SLIC with different weights, m

K = 256; % number of cluster centers
compactness = [10, 25, 40]; %m: weight 10 default for SLIC paper

for i = 1:1%length(compactness)
    [cIndMap, time, imgVis] = slic(im,K,compactness(i));
end


%% Part c: show error map at initialization and at convergence



%% Part d: Show 3 superpixel result with K = [64, 256, 1024]

% K = [64, 256, 1024];
% timesK = zeros(3,1);
% m = 25;
% for i = 1:length(K)
%     tic
%     [cIndMap, time, imgVis] = slic(im,K,compactness);
%     figure(i);
%     plot(imgVis);
%     title(['Steve Macenski Part D K = ' num2str(compactness(i))]);
%     timesK(i) = toc;
% end

%% Part e: eval and show perforamce with K varying-> boundary recall, under segmenetation error, and average run time per image in BSD
