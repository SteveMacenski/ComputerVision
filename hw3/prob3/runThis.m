
% (c) Steve Macenski 2017

load('prob3.mat');
im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));


%% part A
    % use set of matched points to estimate Fundamental matrix using RANSAC
    % with 8 pts algorithm

% plot matches for visualization
%figure(1)
%plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches');

iterations = 20000;
[F, inliers_bool ] = getF(iterations,c1,r1,c2,r2,matches);
F

q=1;w=1;
for i = 1:length(matches(:,1))
   if inliers_bool(i) == 1
      inliers_ind(w,:) = matches(i,:);
      w = w + 1;
   else
      outliers_ind(q,:) = matches(i,:);
      q = q + 1;
   end
end

% plot outliers
figure(2)
imshow(im1);
hold on;
plot(c1(outliers_ind(:,1)),r1(outliers_ind(:,1)),'g.');

%% part B
    % use set of matched points to plot epipolar lines of 7 pts with inliers
figure(3)
subplot(1,2,1);

imshow(im1);
hold on;
IDX = floor(length(inliers_ind)/7);
x = linspace(1,size(im1,2),300);
for i = 1:7
    lines = F'*[c2(inliers_ind(i*IDX,2));r2(inliers_ind(i*IDX,2));1];
    plot(c1(inliers_ind(i*IDX,1)),r1(inliers_ind(i*IDX,1)),'r+'); 
    y = -lines(1)/lines(2).*x - lines(3)/lines(2);
    plot(x,y,'g')
end

subplot(1,2,2);
imshow(im2);
hold on;
IDX = floor(length(inliers_ind)/7);
x = linspace(1,size(im2,2),300);
for i = 1:7
    lines = F*[c1(inliers_ind(i*IDX,1));r1(inliers_ind(i*IDX,1));1];
    plot(c2(inliers_ind(i*IDX,2)),r2(inliers_ind(i*IDX,2)),'r+'); 
    y = -lines(1)/lines(2).*x - lines(3)/lines(2);
    plot(x,y,'g')
end

