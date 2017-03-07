
% (c) Steve Macenski 2017

load('prob3.mat');
im1 = im2double(imread('chapel00.png'));
im2 = im2double(imread('chapel01.png'));

current_inliers = 0;

%% part A
    % use set of matched points to estimate Fundamental matrix using RANSAC
    % with 8 pts algorithm

% plot matches for visualization
figure(1)
plotmatches(im1,im2,[c1 r1]',[c2 r2]',matches');

%RANSAC
for z = 1:50

    % pick 8 random matches
    rand_matches = randi([1,length(matches)],8,1)
    pts_8 = matches(rand_matches,:); % returns 8 points of random index
    %selected match indices to find F before RANSAC
    %rand_matches = [107,229,188,104,209,184,126,111]';
    %pts_8 = matches(rand_matches,:); % returns 8 points of random index

    % normalize the match coordinates
        %ref https://www.mathworks.com/matlabcentral/fileexchange/54544-normalise2dpts-pts-/content/normalise2dpts.m
    stdim1 = [(c1(pts_8(:,1)) - mean(c1(pts_8(:,1)))).^2, (r1(pts_8(:,1)) - mean(r1(pts_8(:,1)))).^2];
    stdim2 = [(c2(pts_8(:,2)) - mean(c2(pts_8(:,2)))).^2, (r2(pts_8(:,2)) - mean(r2(pts_8(:,2)))).^2];
    scale1 = sqrt(2)  /   std(sqrt(sum(stdim1,1))); %scale so that std=sqrt(2)
    scale2 = sqrt(2)  /   std(sqrt(sum(stdim2,1))); %TODO 2? 

    T    =  [scale1,0, -scale1*mean(c1((pts_8(:,1)))) ; 0,scale1, -scale1*mean(r1((pts_8(:,1)))) ; 0,0,1];
    Tnew =  [scale2,0, -scale2*mean(c2((pts_8(:,2)))) ; 0,scale2, -scale2*mean(r2((pts_8(:,2)))) ; 0,0,1];

    x1n = stdim1(:,1)*scale1;
    y1n = stdim1(:,2)*scale1;
    x2n = stdim2(:,1)*scale2;
    y2n = stdim2(:,2)*scale2;

    % write system of linear eqns
    A = zeros(8,9);
    for i = 1:8
        A(i,:)  = [x1n(i)*x2n(i),    x1n(i)*y2n(i),    x1n(i),    y1n(i)*x2n(i), ...
                   y1n(i)*y2n(i),    y1n(i),    x2n(i),    y2n(i),    1];
    end

    % solve using SVD
    [U, S, V] = svd(A);
    f = V(:, end);
    Ftemp = reshape(f, [3 3])';

    [U, S, V] = svd(Ftemp);
    S(3,3) = 0; %enforce constraint det(F)=0;
    F = U*S*V';

    % denormalize
    F = Tnew'*F*T;
    F = F ./norm(F);
    
    % get number of inliers TODO
    
    
    
    %this section RETURN inliers_list
    
    if length(inliers_list) > current_inliers
       current_inliers = length(inliers_list);
       inliers = inlier_list;
       F_best  = F;
    end
end
    
Fundamental_Matrix = F_best;
inliers_matches = inliers;
outlier_matches = matches(setdiff(matches,inliers),:);

% plot outliers TODO


%% part B
    % use set of matched points to plot epipolar lines of 7 pts with inliers
    %TODO
    