function [T,im_aligned] = align_shape( im1, im2 )
% align_shape to align images
%   Steve Macenski (c) 2017

tic;

%find mean locations
[xIm1,yIm1] = find(im1);
[xIm2,yIm2] = find(im2);
meanX1 = mean(xIm1);
meanX2 = mean(xIm2);
meanY1 = mean(yIm1);
meanY2 = mean(yIm2);

% find diff in scale setup
dist1 = hypot(xIm1-meanX1,yIm1-meanY1);
dist2 = hypot(xIm2-meanX2,yIm2-meanY2);
dist1 = sum(dist1)/length(xIm1);
dist2 = sum(dist2)/length(xIm2);

% rotation by variance of scaled object shape setup
rot1=pca([xIm1, yIm1]);
rot2=pca([xIm2, yIm2]);

%rotation, scale, and translation (after applied scale and rotation)
rot=rot2/rot1;
scale = dist2/dist1;

updatedIm1 = scale*rot*[xIm1,yIm1]';
meanInitX = mean(updatedIm1(1,:));
meanInitY = mean(updatedIm1(2,:));
translation = [meanX2-meanInitX; meanY2-meanInitY];

% initial transformation, affine with scaling rotation matrix
T = eye(4);
T = [rot*scale, [translation(1);translation(2)]];

im1pts = [xIm1, yIm1];
im1pts = [im1pts ones(size(xIm1))]; % for matrix math
im2pts = [xIm2, yIm2];

for i = 1:7
    im_aligned = zeros(size(im1));

    im1to2pts = transpose(T*im1pts');
    
    for j = 1:size(im1to2pts,1)    
       % must be on a pixel value, not floating point
       xpos = round(im1to2pts(j,1));
       ypos = round(im1to2pts(j,2));
       % must still be in image
        if (xpos>0 && ypos>0 &&  xpos<=size(im1,1) && ypos<=size(im1,2))
            im_aligned(xpos,ypos) = 1; 
        end
    end
  

    
    % find k neighbors
    [IDX, D] = knnsearch(im2pts, im1to2pts);
    
    
    
    tx = im2pts(IDX,:);
    A = zeros(size(im1pts)*2);
    for k = 1:size(im1pts,1)
       A(2*k-1,1:3) = im1pts(k,:);
       A(2*k,4:6) = im1pts(k,:);
    end
    
    %find new transformation
    tx = tx';
    b = tx(:);
    T  =A\b;
    T = reshape(T,[3,2])';
    
end

% find error and run time
error = evalAlignment(im_aligned, im2);
time_to_run = toc;
end

