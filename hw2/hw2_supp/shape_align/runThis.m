% For testing HW2 P2
%Steve Macenski (c) 2017

im1 = imread('object1.png')>0;
im2 = imread('object2.png')>0;
im2t = imread('object2t.png')>0;
im3 = imread('object3.png')>0;

% image 2 to 1
[Ta,im_alignedA,errorA,timeA] = align_shape(im2,im1);
figure(1)
imshow(displayAlignment(im2,im1,im_alignedA));
title(['Steve Macenski im 2 - 1, time = ' num2str(timeA) ', error = ' num2str(errorA)])

% image 2 to 2t
[Tb,im_alignedB,errorB,timeB] = align_shape(im2,im2t);
figure(2)
imshow(displayAlignment(im2,im2t,im_alignedB));
title(['Steve Macenski im 2 - 2t, time = ' num2str(timeB) ', error = ' num2str(errorB)])

%image 2 to 3
[Tc,im_alignedC,errorC,timeC] = align_shape(im2,im3);
figure(3)
imshow(displayAlignment(im2,im3,im_alignedC));
title(['Steve Macenski im 2 - 3, time = ' num2str(timeC) ', error = ' num2str(errorC)])