function bmap = edgeOrientedFilters( im )
% call oriented FilterMagnitude and perform non-maxima suppression with
% output of a soft image map, bmap 
%   Steve Macenski 2017

% call oriented filter mag function
[magnitude, orientation] = orientedFilterMagnitude(im);

% perform non-maximum suppression, this time with Prewitt
prewitt = edge(rgb2gray(im), 'prewitt');
magnitude = magnitude.*(prewitt > 0);

bmap = abs(magnitude);
bmap = bmap / max(max(bmap));
end

