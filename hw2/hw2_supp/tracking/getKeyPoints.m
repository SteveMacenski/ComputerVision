function [ keyXs, keyYs ] = getKeyPoints( im, tau )
%Take image and threshold value and return key points for feature tracking
%   Steve Macenski (c) 2017

%convert to grayscale
if size(im, 3) == 3 
  im = rgb2gray(im);
end

%gaussian for smoothing and prewitt for direction grad
                    %fsize, sigma
G = fspecial('gaussian', 7, 1);
P = fspecial('sobel');

%find gradiants, square, and smooth with gaussian
Ix = double(imfilter(im, P));
Ixx = Ix.*Ix;
Ixx = imfilter(Ixx,G);
Iy = double(imfilter(im, P'));
Iyy = Iy.*Iy;
Iyy = imfilter(Iyy,G);
Ixy = Ix.*Iy;
Ixy = imfilter(Ixy,G);

SMM = [Ixx, Ixy;
       Ixy, Iyy];   
   
%k in range [0.04:0.06]
k = 0.05;

%meets criteria, then it can be a marker
    %   det SMM               trace SMM
im_criteria = Ixx.*Iyy-Ixy.*Ixy   -   k*(Ixx + Iyy).^2;
harris_criteria = (  im_criteria   >   tau  );

%Local non-maxima suppression TODO
window_size = 5;
suppression = ordfilt2( harris_criteria,   (2*window_size+1)^2,   ones(2*window_size+1) );
suppression = ~suppression;
[keyYs, keyXs] = find(suppression);

end

