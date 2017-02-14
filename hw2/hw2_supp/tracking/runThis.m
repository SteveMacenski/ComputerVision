%Steve Macenski (c) 2017

% Hw2 problem 1: keypoint selection

im = imread('./images/hotel.seq0.png');
tau = 250000; %how to find? TODO

[X, Y] = getKeyPoints(im, tau);

figure(1)
imshow(im);
hold on;
plot(X,Y, 'g.', 'linewidth',3);

title('Steve Macenski Harris Feature Tracker')