function [ mag, theta ] = orientedFilterMagnitude( im )
% Implementation of an oriented filter with at least 4 orientations
%   Steve Macenski 2017

    %define filters
    filters = makeLMfilters;
    num_filters = 18;
    
    %show filters and get filters of input image
    for i = 1:num_filters;  %6 directions, 3 scales, LM, to truncate old other filters
        filtered_im(:,:,i)=imfilter(im,filters(:,:,i),'conv');
        %visualize with imagesc(responses(:,:,1-48))
        %imagesc(filtered_im(:,:,i))
        %pause
    end

    % size the magnitude and populate
    horSize = size(im,1);
    vertSize = size(im,2);
    mag = zeros(horSize, vertSize, num_filters);
    
    for i = 1:size(horSize);
        for j = 1:size(vertSize);
           for k = 1:num_filters;
               if filtered_im(i,j,k) > mag(i,j)
                   mag(i,j) = filtered_im(i,j,k);
               end
           end
        end
    end
    
    % orientation
    
end

