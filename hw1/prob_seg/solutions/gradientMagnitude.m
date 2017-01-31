function [mag, theta] = gradientMagnitude(im, sigma)
% Take in RBG image, smooth with gaussian and compute X/Y gradiants
%Using L2-norm for RGB parts, find orientation and output mag, theta
%of size im
% Steve Macenski 2017

%apply a gaussian blur
G = fspecial('gaussian', 9, sigma);
blurred_im = imfilter(im, G);

%find gradiants of the blurred image
x_grad = double(imfilter(blurred_im, [1, 0, -1]));
y_grad = double(imfilter(blurred_im, [1, 0, -1]));
grad = sqrt(x_grad.^2 + y_grad.^2);


%find magnitude of the gradients
mag = sqrt(grad(:,:,1).^2 + ... %R
           grad(:,:,2).^2 + ... %G
           grad(:,:,3).^2);     %B

%find orientation of the gradiants
ProjXthetas = x_grad ./ grad;
ProjYthetas = y_grad ./ grad;

orientations = atan2(ProjXthetas, ProjYthetas);

horSize = size(im,1); vertSize = size(im,2);
theta = zeros(horSize, vertSize);

for i = 1:size(horSize)
    for j = 1:size(vertSize)
        for k = 1:3
            if theta(i,j) < orientations(i,j,k)
                theta(i,j) = orientations(i,j,k);
            end
        end
    end
end

end

