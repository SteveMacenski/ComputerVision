function bmap = edgeOrientedFilters( im )
% call oriented FilterMagnitude and perform non-maxima suppression with
% output of a soft image map, bmap 
%   Steve Macenski 2017

% call oriented filter mag function
[magnitude, orientation] = orientedFilterMagnitude(im);

% perform non-maximum suppression, same as in edgeGradient
NMaxSuppressionMagnitude = nonmax(magnitude, orientation);

bmap = abs(NMaxSuppressionMagnitude.^(0.7));
end

