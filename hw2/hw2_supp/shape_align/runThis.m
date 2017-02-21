% Testing HW2 P2
%Steve Macenski (c) 2017

% image 1 to 2
Ta = align_shape(imread('object2.png')>0,imread('object1.png')>0);

% image 2 to 2t
Tb = align_shape(imread('object2.png')>0,imread('object2t.png')>0);

%image 2 to 3
Tc = align_shape(imread('object2.png')>0,imread('object3.png')>0);
