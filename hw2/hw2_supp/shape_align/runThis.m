% For testing HW2 P2
%Steve Macenski (c) 2017

im1 = imread('object1.png')>0;
im2 = imread('object2.png')>0;
im2t = imread('object2t.png')>0;
im3 = imread('object3.png')>0;

% image 1 to 2
[Ta,im_alignedA] = align_shape(im2,im1);
figure(1)
imshow(displayAlignment(im2,im1,im_alignedA));

% image 2 to 2t
[Tb,im_alignedB] = align_shape(im2,im2t);
figure(2)
imshow(displayAlignment(im2,im2t,im_alignedB));

%image 2 to 3
[Tc,im_alignedC] = align_shape(im2,im3);
figure(3)
imshow(displayAlignment(im2,im3,im_alignedC));
