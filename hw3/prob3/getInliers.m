function [ inliers_list ] = getInliers( c1,r1,c2,r2,matches,F )
% finds the RANSAC inliers 
% (c) Steve Macenski 2017

    % mark known matched points in each image
    p1 = [c1(matches(:,1)), r1(matches(:,1))];
    p2 = [c2(matches(:,2)), r2(matches(:,2))];

    % map points in im1 to im2
    coor2 = F*[p1,ones(length(p1),1)]';
    Len2 = sqrt(coor2(1,:).^2 + coor2(2,:).^2);
    
    % map points in im2 to im1
    coor1 = F'*[p2,ones(length(p2),1)]';
    Len1 = sqrt(coor1(1,:).^2 + coor1(2,:).^2);
    
    % find distance between projections im1->im2 im2->im1
    dist1 = abs(sum([p1,ones(length(p1),1)]'.*coor1))./Len1;
    dist2 = abs(sum([p2,ones(length(p2),1)]'.*coor2))./Len2;

    %institute a threshold
    direction1_ok = dist1 < 2.5;
    direction2_ok = dist2 < 2.5;

    %return bool list of "okay"s
    inliers_list = (direction1_ok & direction2_ok);
end

