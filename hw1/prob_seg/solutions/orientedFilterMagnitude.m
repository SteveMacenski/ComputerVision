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
        
        %TODO check if normalization is required?
    end

    % size the magnitude and populate
    horSize = size(im,1);
    vertSize = size(im,2);
    mag = zeros(horSize, vertSize);
    
    for i = 1:size(horSize);
        for j = 1:size(vertSize);
           for k = 1:num_filters;
               if filtered_im(i,j,k) > mag(i,j)
                   mag(i,j) = filtered_im(i,j,k);
               end
           end
        end
    end
    
    % Find orientation of max channel
    theta = zeros(horSize, vertSize);

    orientations_of_filters = 0:pi/6:pi;
    orientations_of_filters = orientations_of_filters(1:end-1);

    for i = 1:size(horSize);
        for j = 1:size(vertSize);
           for k = 1:num_filters;
               if filtered_im(i,j,k) == mag(i,j)
                   
                   %compute the angle TODO
                   if k == 1 || k == 7 || k ==13 
                       theta(i,j) = orientations_of_filters(1)
                   elseif k == 2 || k == 8 || k ==14 
                       theta(i,j) = orientations_of_filters(2)
                   elseif k == 3 || k == 9 || k ==15 
                       theta(i,j) = orientations_of_filters(3)
                   elseif k == 4 || k == 10 || k ==16 
                       theta(i,j) = orientations_of_filters(4)
                   elseif k == 5 || k == 11 || k ==17 
                       theta(i,j) = orientations_of_filters(5)
                   elseif k == 6 || k == 12 || k ==18 
                       theta(i,j) = orientations_of_filters(6)
                   end
                   
               end
           end
        end
    end
    
end

