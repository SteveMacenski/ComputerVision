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

%rotation, scale, and translation
rot=rot2/rot1;
scale = dist2/dist1;
translation = scale*[meanX2-meanX1; meanY2-meanY1]; %scale here, TODO
%overshooting the translation every time

% initial transformation
T = eye(4);
translation = scale*rot*translation;
T = [rot*scale, [translation(1);translation(2)]];

im_aligned = zeros(size(im1));
im1pts = [xIm1, yIm1];
im1pts = [im1pts ones(size(xIm1))];
im2pts = [xIm2, yIm2];

for i = 1:7
    
    im1to2pts = transpose(T*im1pts');
    
    for j = 1:size(im1pts,1)
       
        if (round(im1to2pts(j,1))>=0 &&... 
            round(im1to2pts(j,2))>=0 &&...
            round(im1to2pts(j,1))<=size(im1,1) &&...
            round(im1to2pts(j,2))<=size(im1,2))
        
              im_aligned(round(im1to2pts(j,1)),...
                         round(im1to2pts(j,2))) = 1; 
        end
    end
  
    error(i) = evalAlignment(im_aligned, im2);
    
     %find k neighbors
     [IDX, D] = knnsearch(im2pts, im1to2pts);
%     
%     tx = im2pts(IDX,:);
%     A = zeros(size(im1pts)*2);
%     for k = 1:size(im1pts,1)
%        A(2*k-1,1:3) = im1pts(k,:);
%        A(2*k,4:6) = im1pts(k,:);
%     end
%     
%     %find new transformation
%     tx = tx';
%     b = tx(:);
%     T  =A\b;
%     T = reshape(T,[3,2])';
    
end

time_to_run = toc; %unsuppress to display

% figure (4)
% imshow(im_aligned)

end

