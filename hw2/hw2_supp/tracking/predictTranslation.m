function [ newX, newY ] = predictTranslation( startX, startY, Ix, Iy, im0, im1 )
%predictTranslation, for single X,Y positions
% Will interpolate Ix,Iy,im0,im1 for non-integer locations

%   Steve Macenski (c) 2017

  % find local 15x15 window It for current point
  [localX, localY] = meshgrid(startX-7:startX+7, startY-7:startY+7);
  It = interp2(im1,localX, localY, 'linear') - ...
            interp2(im0,localX, localY, 'linear');

  % find sums to populate A and b matrices
  sumIx = sum(sum(Ix.*Ix));
  sumIy = sum(sum(Iy.*Iy));
  sumIxy = sum(sum(Ix.*Iy));
  sumIxt = sum(sum(Ix.*It));
  sumIyt = sum(sum(Iy.*It));
  
  % solve system of equations
  A = [sumIx, sumIxy;
       sumIxy, sumIy];
  b = [-sumIxt; -sumIyt];
  x = A\b;
  u = x(1); v = x(2);
  
  %update guess
  newX = startX + u;
  newY = startY + v;

end

