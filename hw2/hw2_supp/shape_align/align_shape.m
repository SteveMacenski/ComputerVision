function [T,im_aligned,error,time_to_run] = align_shape( im1, im2 )
% align_shape to align images
%   Steve Macenski (c) 2017

    tic;

    %%%%%%%%% setup
    
    %find mean locations
    [xIm1,yIm1] = find(im1);
    [xIm2,yIm2] = find(im2);
    meanX1 = mean(xIm1);
    meanX2 = mean(xIm2);
    meanY1 = mean(yIm1);
    meanY2 = mean(yIm2);

    % find diff in scale setup
    dist1 = hypot(xIm1-meanX1,yIm1-meanY1);
    dist2 = hypot(xIm2-meanX2,yIm2-meanY2);
    dist1 = sum(dist1)/length(xIm1);
    dist2 = sum(dist2)/length(xIm2);

    % rotation by variance of scaled object shape setup
    rot1=pca([xIm1, yIm1]);
    rot2=pca([xIm2, yIm2]);

    %rotation, scale, and translation (after applied scale and rotation)
    rot=rot2/rot1;
    scale = dist2/dist1;

    updatedIm1 = scale*rot*[xIm1,yIm1]';
    meanInitX = mean(updatedIm1(1,:));
    meanInitY = mean(updatedIm1(2,:));
    translation = [meanX2-meanInitX; meanY2-meanInitY];

    % initial transformation, affine with scaling rotation matrix
    T = [rot*scale, [translation(1);translation(2)]]; %2x3

    im1pts = [xIm1, yIm1];
    im1pts = [im1pts ones(size(xIm1))]; % for matrix math
    im2pts = [xIm2, yIm2];
    
    %%%%%%%%% iterations with ICP algorithm

    for i = 1:5
        im_aligned = zeros(size(im1));

                                                                              % (5 apply transformation im1->2)
        im1to2pts = transpose(T*im1pts');

        for j = 1:size(im1to2pts,1)    
            
           % must be on a pixel value, not floating point
           xpos = round(im1to2pts(j,1));
           ypos = round(im1to2pts(j,2));
           
           % must still be in image, to show
                                                                              % (show image for debugging)
            if (xpos>0 && ypos>0 &&  xpos<=size(im1,1) && ypos<=size(im1,2))
                im_aligned(xpos,ypos) = 1; 
            end
        end

                                                                              % (3 find KNN for transformed image)
        %IDX has index in im2pts corresponding to nearest neighbor in im1to2pts
        IDX = knnsearch(im2pts, im1to2pts);

                                                                              % (3 sort im2 pts near im1 transformed)
        % maps current transformed im1to2pts to im2pts: 'y'. (reorders)
        b = im2pts(IDX,:);
                                                                              % (4 find T WARPING for im1 points to im2 points from KNN im1->2, averaged out via all pixels hence why not extreme warping in off regions)
        %find new transformation w/ least square fit 'A': y = A*p
        for k = 1:size(im1to2pts,1)
           A(k,1:3) = im1pts(k,:);
        end
        
        T = (A\b)' % 'p'
    end

    % find error and run time
    error = evalAlignment(im_aligned, im2);
    time_to_run = toc;
end

