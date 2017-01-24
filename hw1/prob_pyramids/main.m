% load image, apply gaussian and laplacian pyramids of variable level
% creates output plot using tight_subplot

%Steven Macenski 2017

clear all;
src = './hrs_atlas2.png';

% 5 levels and reduction of 2 as specified by the prompt
[gaussian, laplacian] = gaussian_and_laplacian_pyramid(src, 5, 2);

plot_pyramids(gaussian, laplacian, 2, 5);

%fft funct
%plot_ffts(gaussian, laplacian, 2, 5);
