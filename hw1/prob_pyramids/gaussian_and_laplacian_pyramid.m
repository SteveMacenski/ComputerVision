function [ gaussian, laplacian ] = gaussian_and_laplacian_pyramid( src, num_levels, reduction_factor)
% function to apply gaussian pyramid
%   returns a linear matrix of applied images

% read in images and gray scale
src = imread(src);
gray_src = mat2gray(src);

%config filter, reducation_factor is sigma, hsize?
gaussian{num_levels,1} = [];
laplacian{num_levels-1,1} = [];
gaussian{1} = gray_src;
h = fspecial('gaussian', 9, reduction_factor);

%apply filter
for i = 2:num_levels
    %gaussian pyramid blur
    gaussian{i} = imfilter(gaussian{i-1}, h);
    
    % laplacian pyramid
    laplacian{i-1} = gaussian{i-1} - gaussian{i};
    
    %gaussian pyramid subsample
    gaussian{i} = imresize(gaussian{i}, [size(gaussian{i-1}, 1)/2, ...
                   size(gaussian{i-1}, 2)/2]); 
    
end


end

