% Steve Macenski (c) 2017
% Graph Cut Segmentation: background/foreground of image with given rough polygon

clc;clear all;
load('cat_poly.mat');
im = im2double(imread('./cat.jpg'));
addpath('./GCmex1.5/');

% parameters and constants
k1 = 5;
k2 = 6;
polyMask = poly2mask(poly(:,1),poly(:,2),size(im,1),size(im,2));
labels = polyMask; %initial labels are polygon mask given

% (1) define graph
DataCost = zeros(size(im,1), size(im,2), 2); %cost of assignment of each label at pixel :,:,#L
SmoothnessCost = [0 1; 1 0]; %LxL matrix of costs to assign neighbor pixels
vC = zeros(size(im,1),size(im,2),1); %spatially varying smoothness cost
hC = zeros(size(im,1),size(im,2),1); %spatially varying smoothness cost
data = reshape(im, [size(im,1) * size(im,2), size(im,3)]); %reshaped for fitgmdist

% (3) pairwise potentials constants
gauss = fspecial('gaussian', [9 9], sqrt(9));
gradX = abs(imfilter(im,gauss ,'same'));
gradY = abs(imfilter(im,gauss','same'));
for i = 1:size(im,3)
    vC = k1 + k2 .* exp(-gradX(:,:,i));
    hC = k1 + k2 .* exp(-gradY(:,:,i));
end

for STEP = 1
    
    %(2) unary potententials
    foreGround = data(labels==1, :);
    backGround = data(labels==0, :);
    
    foreProbGmm = fitgmdist(foreGround, 3); % X observations
    foreProb = foreProbGmm.pdf(data); % pdf of data from X observations
    backProbGmm = fitgmdist(backGround, 3);
    backProb = backProbGmm.pdf(data);
    foreProb = reshape(foreProb, size(im,1), size(im,2)); % shape to mask
    backProb = reshape(backProb, size(im,1), size(im,2));

    DataCost(:,:,1) = -log(foreProb ./ backProb);
    DataCost(:,:,2) = -log(backProb ./ foreProb);
    
    %(3) pairwise potentials  
    
    %(4) apply graph cuts (open, unary term, data indep. smoothing, contrast smoothing)
    [gch] = GraphCut('open', DataCost, SmoothnessCost, vC, hC);
    [gch, labels] = GraphCut('swap', gch); % why swap not get? 
    gch = GraphCut('close', gch);
    
    reshape(labels, [size(im, 1)*size(im, 2), 1]); % reshape to data
end

% display results: foreground/background P map and final segmentation
labels = reshape(labels, size(im,1), size(im,2)); %reshape to image
foreProb = reshape(foreProb, size(im,1), size(im,2));

mask = 1-ones(size(im));
mask(:,:,1) = labels; mask(:,:,2) = labels; mask(:,:,3) = labels;
segmentedImage = im .* (1-mask);
segmentedImage(:,:,3) = (segmentedImage(:,:,3)==0)*128;

figure(1);
imagesc(segmentedImage); % final segementation

figure(2);
subplot(1,2,1)
imagesc(foreProb); % P map
subplot(1,2,2)
imagesc(backProb);

figure(3);
imagesc(mask); %mask