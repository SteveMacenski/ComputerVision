%Steve Macenski (c) 2017
clc;clear all;

%% affine structure for motion
load('tracked_points.mat'); % grabs tracked points Xs,Ys 51x491

num_images = size(Xs,1); % number of images 
num_tracked = size(Xs,2); % number of points tracked in images

%center feature coordinates
for i = 1:num_images
    XImMean = mean(Xs(i,:));
    YImMean = mean(Ys(i,:));
    
    % normalize coordinates
    xHat = Xs(i,:) - XImMean;
    yHat = Ys(i,:) - YImMean;
  
    % construct D
    D(i,:) = xHat;
    D(i+num_images,:) = yHat;
end

% Factorize, SVD, generate motion (affine) and shape (3D) matrices
[U,S,V] = svd(D);
U = U(:,1:3);
V = V(:,1:3);
W = S(1:3,1:3);

A = U*sqrt(W); % initial affine matrix
X = sqrt(W)*V'; % initial shape matrix

% eliminate affine ambiguity
for i = 1:num_images
    p1 = A(i,:);
    p2 = A(i+num_images,:);
    CCT(3*i-2,:) = [p1(1)^2, p1(1)*p1(2), p1(1)*p1(3), p1(1)*p1(2), p1(2)^2, p1(2)*p1(3), p1(1)*p1(3), p1(2)*p1(3), p1(3)^2];
    CCT(3*i-1,:) = [p2(1)^2, p2(1)*p2(2), p2(1)*p2(3), p2(1)*p2(2), p2(2)^2, p2(2)*p2(3), p2(1)*p2(3), p2(2)*p2(3), p2(3)^2];
    CCT(3*i,:) = [p1(1)*p2(1), p1(1)*p2(2), p1(1)*p2(3), p1(2)*p2(1), p1(2)*p2(2), p1(2)*p2(3), p2(1)*p1(3), p2(2)*p1(3), p2(3)*p1(3)];
    b(3*i-2,:) = 1;
    b(3*i-1,:) = 1;
    b(3*i,:) = 0;
end

Amat = CCT;
L = Amat \ b; % Least Squares solution to tracked points
L = reshape(L,[3 3])';
C = chol(L,'lower');
A = A * C;
X = C \ X;

% find camera motion, kf = if X jf
for i = 1:num_images
    Kf_temp = cross(A(i,:), A(i+num_images,:));
    Kf(i,:) = Kf_temp./norm(Kf_temp); % to normalize
end
   
%% outputs 

% plot 3D predicted location of tracked points (save 3 views)
figure(1)
plot3(X(1,:),X(2,:),X(3,:),'b.');
title('Steve Macenski - Tracked 3D Building')

% plot predicted 3D path of the caameras, given by kf = if X jf, normalized
figure(2)
plot(Kf(:,1));
title('Path of 3D camera, direction 1')
figure(3)
plot(Kf(:,2)); 
title('Path of 3D camera, direction 2')
figure(4)
plot(Kf(:,3));
title('Path of 3D camera, direction 3')



