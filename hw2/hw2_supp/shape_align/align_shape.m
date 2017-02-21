function T = align_shape( im1, im2 )
% align_shape to align images
%   Steve Macenski (c) 2017

tic;

%find mean locations and translation
[xIm1,yIm1] = find(im1);
[xIm2,yIm2] = find(im2);
meanX1 = mean(xIm1);
meanX2 = mean(xIm2);
meanY1 = mean(yIm1);
meanY2 = mean(yIm2);

translation = [meanX2-meanX1; meanY2-meanY1];

% find diff in scale
dist1 = hypot(xIm1-meanX1,yIm1-meanY1);
dist2 = hypot(xIm2-meanX2,yIm2-meanY2);
dist1 = sum(dist1)/length(xIm1);
dist2 = sum(dist2)/length(xIm2);

scale = dist2/dist1;

% find rotation by variance of scaled object shape
x1 = (xIm1-meanX1)/length(xIm1)*scale;
y1 = (yIm1-meanY1)/length(yIm1)*scale;
x2 = (xIm1-meanX1)/length(xIm2);
y2 = (yIm1-meanY1)/length(yIm2);
rot1 = atan2(y1,x1);
rot2 = atan2(y2,x2);

rot = rot2-rot1;

% scale image 1, transform, and rotate from initial findings 


%iterate
%       TODO assign each point in 1 to nearest neighbor in 2

%       TODO estimate transformation params


im_align = [];


time_to_run = tock %unsuppress to display

figure (1)
imshow(displayAlignment(im1,im2,im_align));

end

