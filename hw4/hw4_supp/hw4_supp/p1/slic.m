function [cIndMap, time, imgVis] = slic(im, K, m)

%% Implementation of Simple Linear Iterative Clustering (SLIC)
%
% Input:
%   - im: input color image
%   - K:   number of clusters
%   - compactness: the weighting for compactness
% Output:
%   - cIndMap: a map of type uint16 storing the cluster memberships
%   - time:    the time required for the computation
%   - imgVis:  the input image overlaid with the segmentation

tic;
debugOn = false;
convergance = false;

im_gray = double(rgb2gray(im));
imgVis = double(im);
im = double(rgb2lab(im)); %Lab colorspace for SLIC 

N = size(im,1)*size(im,2); % # pixels
S = floor(sqrt(N/K)); % S for window size

% make initial cluster centers
K = sqrt(K);
range1 = S:1.3*S:size(im,1)-S;
range2 = S:1.3*S:size(im,2)-S;

k=1;
for i = 1:length(range1)
    for j = 1:length(range2)
        cluster_centers(k,:) = [round(range1(i)), round(range2(j)), im(i,j,1), im(i,j,2), im(i,j,3)];
        k=k+1;
    end
end
cluster_centers = unique(cluster_centers,'rows'); % kill redundant clusters

if debugOn==true %initial placement of centers
    figure(1)
    imshow(imgVis);
    hold on;
    scatter(cluster_centers(:,2),cluster_centers(:,1),'r+');
end

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

if debugOn==true % placement of centers after grad minimization
    figure(1)
    scatter(cluster_centers(:,2),cluster_centers(:,1),'b+');
end

% zeroing out distance and label
d = 9e99*ones([size(im,1), size(im,2)]);
label = -1*ones([size(im,1), size(im,2)]);


%% segmentation iteration
for STEP = 1:10
    %  For each cluster, find the distance between pixels in [2S 2S] window
    for i = 1:size(cluster_centers,1)
        Sx=S;Sy=S;
        xBot = cluster_centers(i,1)-S;
        xTop = cluster_centers(i,1)+S;
        yBot = cluster_centers(i,2)-S;
        yTop = cluster_centers(i,2)+S;

        if xBot < 1
            xBot = 1;
            Sx = cluster_centers(i,1)-1; 
        end
        if yBot < 1
            yBot = 1;
            Sy = cluster_centers(i,2)-1;
        end        
        if xTop > size(im,1)
            xTop = size(im,1);
        end  
        if yTop > size(im,2)
            yTop = size(im,2);
        end 
        
        ROI = im(xBot:xTop, yBot:yTop, :);
        
        for v1 = 1:size(ROI,1)
            for v2 = 1:size(ROI,2)
                dir1 = v1 + cluster_centers(i,1) - Sx - 1;% coords of ROI pixels
                dir2 = v2 + cluster_centers(i,2) - Sy - 1;
                
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
        if numpxl == 0
            numpxl = 1; %stop nans
        end
        cluster_centers_new(i,:) = [round(posX/numpxl),round(posY/numpxl),L/numpxl,a/numpxl,b/numpxl];
    end
    
    % compute residual error
    error = zeros(size(im,1), size(im,2), STEP);
    err = zeros(size(im,1), size(im,2));
    for i = 1:size(im,1)
        for j = 1:size(im,2)
            cluster = label(i,j);
            if cluster ~= -1
                err(i,j) = norm(cluster_centers_new(cluster,:) - [i, j, im(i,j,1), im(i,j,2), im(i,j,3)] );
            end
        end
    end
    error(:,:,STEP) = err;
    
    if STEP == 1 && convergance == true
       figure(3)
       imagesc(log(err));
       title('Error map at initialization')
    end
    
    % assign to loop over next iteration
    cluster_centers = cluster_centers_new;
    
    if debugOn==true %cluster movement 
        figure(1)
        scatter(cluster_centers(:,2),cluster_centers(:,1),'g+');
        pause(.5)
    end
end

%% 
% enforce connected components
CC = zeros(size(im,1), size(im,2), size(cluster_centers,1));
for i = 1:size(cluster_centers,1)
    label_i = (label==i);
    label_i = bwconncomp(label_i,8);
    tempID = [];
    for q = 1:size(label_i.PixelIdxList,2)
        if size(label_i.PixelIdxList{q},1) > size(tempID,1)
            tempID = label_i.PixelIdxList{q};
        end
    end
    [xin,yin] = ind2sub([size(im,1),size(im,2)],tempID);
    pts = [xin,yin];
    for g = 1:size(pts,1)
        CC(pts(g,1),pts(g,2),i) = i;
    end
end

for i = 1:size(im,1)
    for j = 1:size(im,2)
        label(i,j) = sum(CC(i,j,:));
    end
end

% with connected parts, find new centers
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
    if numpxl == 0
        numpxl = 1; %stop nans
    end
    cluster_centers(i,:) = [round(posX/numpxl),round(posY/numpxl),L/numpxl,a/numpxl,b/numpxl];
end

%join orphaned pixels to closest geometric center
for x = 1:size(im,1)
    for y = 1:size(im,2)
        if label(x,y) <= 0 || label(x,y) == 104
            dist_min = inf;
            for cluster = 1:size(cluster_centers,1)   
                
                ds2 = (cluster_centers(cluster,1) - x)^2 + (cluster_centers(cluster,1) - y)^2;
                dc2 = (cluster_centers(cluster,3) - im(x,y,1))^2 + ...
                    (cluster_centers(cluster,4) - im(x,y,2))^2 + ...
                    (cluster_centers(cluster,5) - im(x,y,3))^2;
                D = m^2/S^2*ds2 + dc2;
                 D = (cluster_centers(cluster,1) - x)^2 + (cluster_centers(cluster,2) - y)^2;                
                if D < dist_min
                    label(x,y) = cluster;
                    dist_min = D;
                end            
            end
        end
    end
end

% add orphaned to error maps
err = zeros(size(im,1), size(im,2));
for i = 1:size(im,1)
    for j = 1:size(im,2)
        cluster = label(i,j);
        err(i,j) = norm(cluster_centers_new(cluster,:) - [i, j, im(i,j,1), im(i,j,2), im(i,j,3)] );
    end
end
error(:,:,end) = err;

% make image for viewing with boundaries
filter = [-1 1];  
gradX = imfilter(label,filter );
gradY = imfilter(label,filter');
gradMag = abs(gradX.^2 + gradY.^2) > 0;
gradMag = bwmorph(gradMag,'thin',inf);
imgVis(gradMag)=255;

if debugOn==true
   figure(6)
   imshow(imgVis)
   hold on;
   scatter(cluster_centers(:,2),cluster_centers(:,1),'g+');
   figure(12)
   imagesc(label); hold on; imagesc(label);
end

cIndMap = uint16(label);
time = toc;

% show error map
if convergance == true
    figure(4); clf;
    imagesc(log(error(:,:,end)));
    title('Error map at Convergence')
end
end