function [cIndMap, time, imgVis] = slic(im, K, m)

%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - img: input color image
%   - K:   number of clusters
%   - compactness: the weighting for compactness
% Output: 
%   - cIndMap: a map of type uint16 storing the cluster memberships
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

tic;

% changing color space for SLIC
im_gray = rgb2gray(im);
im_raw = im;
im = rgb2lab(im);

N = size(im,1)*size(im,2); % # pixels
S = floor(sqrt(N/K)); % S for window size

% make initial cluster centers
K = sqrt(K);
range1 = K:K:size(im,1)-K;
range2 = K:K:size(im,2)-K;

k=1;
for j = 1:length(range1)
    for i = 1:length(range2)
        cluster_centers(k,:) = [range1(j), range2(i), im(i,j,1), im(i,j,2), im(i,j,3)];
        k=k+1;
    end
end
cluster_centers = unique(cluster_centers,'rows'); % kill redundant clusters

                                                                                figure(1)
                                                                                imagesc(im_raw)
                                                                                hold on; 
                                                                                plot(cluster_centers(:,2), cluster_centers(:,1), 'r+');

% Move centers to the lowest gradient in the 3x3 neighborhood of center
[gradX,gradY] = gradient(im_gray);
gradMag = gradX.^2 + gradY.^2;

for i = 1:size(cluster_centers,1)
        ROI = gradMag(cluster_centers(i,1)-1:cluster_centers(i,1)+1, ...
                      cluster_centers(i,2)-1:cluster_centers(i,2)+1);
        [val,ind] = min(ROI(:));
        [xin,yin] = ind2sub([3,3],ind);
        cluster_centers(i,1) = cluster_centers(i,1) + xin - 2;
        cluster_centers(i,2) = cluster_centers(i,2) + yin - 2;
        cluster_centers(i,3) = im(cluster_centers(i,1),cluster_centers(i,2),1);
        cluster_centers(i,4) = im(cluster_centers(i,1),cluster_centers(i,2),2);
        cluster_centers(i,5) = im(cluster_centers(i,1),cluster_centers(i,2),3);
end

% zeroing out distance and label
d = 9e99*ones([size(im,1), size(im,2)]);
label = -1*ones([size(im,1), size(im,2)]);

% segmentation iteration
for STEP = 1:10
    STEP
   %  For each cluster, find the distance between pixels in [2S 2S] window
   for i = 1:size(cluster_centers,1)
       
       ROI = im(cluster_centers(i,1)-S:cluster_centers(i,1)+S, ...
                      cluster_centers(i,2)-S:cluster_centers(i,2)+S, :);
                      % ROI form 1L 2a 3b
                      
       for v1 = 1:size(ROI,1)
           for v2 = 1:size(ROI,2)
               dir1 = v1 + cluster_centers(i,1) - S - 1; % coords of ROI pixels
               dir2 = v2 + cluster_centers(i,2) - S - 1;
               
               ds2 = (cluster_centers(i,1) - dir1)^2 + (cluster_centers(i,1) - dir2)^2;
               dc2 = (cluster_centers(i,3) - ROI(v1,v2,1))^2 + ...
                     (cluster_centers(i,4) - ROI(v1,v2,2))^2 + ...
                     (cluster_centers(i,5) - ROI(v1,v2,3))^2;
               D = sqrt(m^2/S^2*ds2 + dc2);
               
               %if distance < D requirement, set d(i) = D, label = cluster ID
               if D < d(dir1,dir2)
                   d(dir1,dir2) = D;
                   label(dir1,dir2) = i;
               end
           end
       end
       
   end
   
   % compute new cluster centers
   for i = 1:size(cluster_centers)
       pix = (label==i);
       L=0;a=0;b=0;posX=0;posY=0;
       for x = 1:size(pix,1)
           for y = 1:size(pix,2)
               if pix(x,y) > 0
                   L = L + im(x,y,1);
                   a = a + im(x,y,2);
                   b = b + im(x,y,3);
                   posX = posX + x;
                   posY = posY + y;
               end
           end
       end
       numpxl = sum(sum(pix));
       cluster_centers_new(i,:) = [round(posX/numpxl),round(posY/numpxl),L/numpxl,a/numpxl,b/numpxl];
       plot(cluster_centers_new(:,2), cluster_centers_new(:,1), 'b+');
   end
   
   % compute residual error, TODO
   err = [];
   for i = 1:size(im,1)
       for j = 1:size(im,2)
           cluster = label(i,j);
           if cluster ~= -1
               err(i,j) = norm(cluster_centers_new(cluster,:) - cluster_centers(cluster,:));
           end
       end
   end
   error(:,:,i) = err;
   
   % assign to loop
   cluster_centers = cluster_centers_new;
   
end




time = toc;

cIndMap = [];
                                                                                plot(cluster_centers(:,2), cluster_centers(:,1), 'g+');
imgVis = [];

% plot error and pixel output, error(i,j,STEP)
end

