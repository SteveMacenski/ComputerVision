% Steve Macenski (c) 2017
% SLIC (Achanta et al. PAMI 2012) implementation
clear all; clc; clf;

% reading in image
im = im2double(imread('./lion.jpg'));

%% Part b: produce plots of SLIC with different weights, m

K = 500; % number of cluster centers
compactness = [1, 10, 25, 40]; %m: weight 10 default for SLIC paper

for i = 1%:length(compactness)
    [cIndMap, time, imgVis] = slic(im,K,compactness(i));
    figure(i+5)
    imshow(imgVis);
    title(['Steve Macenski m=' num2str(compactness(i))]);
    time
end


%% Part c: show error map at initialization and at convergence
% ran instance with convergence = true 

%% Part d: Show 3 superpixel result with K = [64, 256, 1024]
K = [256, 512, 1024];
m = 10;
timeK = [];
for i = 1:length(K)
    [cIndMap, time, imgVis] = slic(im,K(i),m);
    figure(i+5);
    imshow(imgVis);
    title(['Steve Macenski Part D K = ' num2str(K(i))]);
    timeK(i) = time
end

%% Part e: eval and show perforamce with K varying-> boundary recall, under segmenetation error, and average run time per image in BSD

