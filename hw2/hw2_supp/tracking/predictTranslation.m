function [ newX, newY ] = predictTranslation( startX, startY, Ix, Iy, im0, im1 )
%predictTranslation, for single X,Y positions
% Will interpolate Ix,Iy,im0,im1 for non-integer locations

%   Steve Macenski (c) 2017

  % find local window Ix, Iy, It for current point
  [localx, localy] = meshgrid(startX-15:startX+15, startY-15:startY+15);
  localIx = interp2(Ix, localX, localY, 'spline'); %try linear
  localIy = interp2(Iy, localX, localY, 'spline'); %try linear
  localIt = %TODO

  % find sums to populate A and b matrices
  sumIx = %TODO sum over windows
  sumIy = 
  sumIxy = 
  sumIxt = 
  sumIyt = 
  
  % solve system of equations
  A = [sumIx, sumIxy;
       sumIxy, sumIy];
  b = [-Ixt; -Iyt];
  x = A\b;
  x(1) = u; x(2) = v;
  
  %update guess
  newX = startX + u;
  newY = startY + v;

end

