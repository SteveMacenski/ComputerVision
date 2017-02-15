function [ newXs, newYs ] = predictTranslationAll( startXs, startYs, im0, im1 )
%predictTranslationAll
%   takes images and starting values. Computes Ix,Iy and finds keypoint
%   translation with predictTranslation

%   Steve Macenski (c) 2017

% initialize 
num_keypoints = length(startYs);
newXs = zeros(num_keypoints,1);
newYs = zeros(num_keypoints,1);

% find gradient of im0
P = fspecial('sobel');
Ix = double(imfilter(im0, P)); %[1, 0, -1]
Iy = double(imfilter(im0, P')); %[1, 0, -1]'

%for each keypoint
for  i = 1:num_keypoints
    
    %given start position
    newX = startXs(i);
    newY = startYs(i);
    
    if (newX < 7 || newY < 7 || newX >= (size(im0,2) - 7) || newY >= (size(im0,1) - 7))
        % out of bounds, 0. all future out of spec since > 7
        
        newXs(i) = 0.;
        newYs(i) = 0.;
       
    else
         % compute local patch Ix and Iy
        [localX, localY] = meshgrid(newX-7:newX+7, newY-7:newY+7);
        localIx = interp2(Ix, localX, localY, 'linear'); %try linear
        localIy = interp2(Iy, localX, localY, 'linear'); %try linear
    
        for j = 1:5
            [newX, newY] = predictTranslation(newX, newY, localIx, localIy, im0, im1);
        end
        
        % store
        newXs(i) = newX;
        newYs(i) = newY;
        
    end
end

end