%Steve Macenski (c) 2017

% Hw2 problem 1: keypoint selection

im = imread('./images/hotel.seq0.png');
tau = 0.035; %how to find? TODO

[X, Y] = getKeyPoints(im, tau);

figure(1)
hold on;
plot(X,Y, 'g.', 'linewidth',3);
figure(2)
imshow(im);
title('Steve Macenski Harris Feature Tracker')