function bmap =edgeGradient(im)

%uses gradiant magnitude to find a soft boundary map
%and perform non-maxima suppression

% Steve Macenski 2017

% Find the gradiant magnitude and orientation
sig = 2;
[magnitude, orientation] = gradiantMagnitude(image, sig);

% Non-max suppression
NMaxSuppressionMagnitude = nonmax(magnitude, orientation);


bamp = NMaxSuppressionMagnitude.^(0.7);

end