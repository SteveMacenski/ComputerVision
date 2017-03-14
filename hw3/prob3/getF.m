function [ Fundamental_Matrix, inliers ] = getF(iterations, c1,r1,c2,r2,matches )
% estimates F for each RANSAC interation to find the best one of N
% interation
% (c) Steve Macenski 2017

current_inliers = -1;

%RANSAC
for z = 1:iterations
    % pick 8 random matches
    rand_matches = randi([1,length(matches)],8,1);
    pts_8 = matches(rand_matches,:); % returns 8 points of random index

    % normalize the match coordinates
        %ref https://www.mathworks.com/matlabcentral/fileexchange/54544-normalise2dpts-pts-/content/normalise2dpts.m
    [ x1n,y1n,x2n,y2n,T,Tnew ] = normalize_iteration( c1,r1,c2,r2,matches,pts_8 );

    % set up linear equations and solve with SVD
    F = solveF(x1n,y1n,x2n,y2n,T,Tnew);
    
    % get number of inliers
    inliers_list = getInliers(c1,r1,c2,r2,matches,F);
        
    if sum(inliers_list) > current_inliers
       current_inliers = sum(inliers_list);
       inliers = inliers_list;
       Fundamental_Matrix  = F;
    end
end
end

