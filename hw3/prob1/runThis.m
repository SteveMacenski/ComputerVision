% run this for problem 1

%Steve Macenski (c) 2017

%% 1A
im = im2double(imread('./kyoto_street.JPG'));

%used to find the vanish points stored below
%vp  = getVanishingPoint_shell(im)
vanishingZuv = [1.0323e+03, -1.6781e+04,1];
vanishingYuv = [-309.7820, 1.5919e+03,1];
vanishingXuv = [7.1262e+03, 1.5750e+03,1];
vanishingZxyz = 1.0e8.*[ 0.1369   -2.2259    0.0001];
vanishingYxyz = 1.0e7.*[ -0.4833    2.4834    0.0016];
vanishingXxyz = 1.0e6.*[ -1.0538    3.3134    0.0017];

% show image and line plot
figure(1)
imagesc(im);
hold on;
line([ 7.1262e+03, -309.7820], [1.5919e+03,1.5750e+03]);
p  = polyfit([ 7.1262e+03, -309.7820], [1.5919e+03,1.5750e+03],1);
    %line is v = 0u+1.5757e3, 0=.0023*u+1*v+1.5757e3, a^2+b^2=1
    % already normalized .0023 so small no contribution

%% 1B
% find the intrinsic matrix 
syms f v0 u0;
KinvTKinv = [f^-2,     0,            -u0/f^2;       ...
             0,       f^-2,          -v0/f^2;       ...
             -u0/f^2, -v0/f^2, (u0/f)^2+(v0/f)^2+1];
cross1 = vanishingZuv * KinvTKinv * vanishingYuv'==0; %d1
cross2 = vanishingYuv * KinvTKinv * vanishingXuv'==0; %d2
cross3 = vanishingXuv * KinvTKinv * vanishingZuv'==0; %d3
sln = solve(cross1,cross2,cross3,f,u0,v0);
f  = double(sln.f(2))
u0 = double(sln.u0(1))
v0 = double(sln.v0(1))

%% 1C
% find rotation matrix

R = [];
K = [f 0 u0; ...
     0 f v0; ...
     0 0 1];
 
 R(:,1) = K\vanishingXxyz';
 R(:,2) = K\vanishingYxyz';
 R(:,3) = K\vanishingZxyz';
 
 % normalize it to norm(R) = 1
R(:,1)  = R(:,1)./norm(R(:,1));
R(:,2)  = R(:,2)./norm(R(:,2));
R(:,3)  = R(:,3)./norm(R(:,3)) %TODO wrong!
norm(R)


%% 1D
im = im2double(imread('./CIMG6476.JPG'));

%used to find the vanish points stored below
%vp  = getVanishingPoint_shell(im)
vanishingYuv = [  -1.0965e+03, 1.2078e+03,1];
vanishingXuv = [   4.9791e+03, 1.2972e+03,1];
vanishingYxyz =  1.0e+08 *[-3.0730    3.3850    0.0028];
vanishingXxyz = 1.0e+08 *[ -6.1917   -1.6131   -0.0012];

figure(2)
imagesc(im);
hold on;
line([4.9791e+03,-1.0965e+03], [1.2972e+03,1.2078e+03]);
axis([-4000,2200,0,2700]);


%% NOTES TO SELF WITH DATA
%axis([-350,7500,0,2200]); %to show line with points
% vert = (1.0323e+03, -1.6781e+04) (u,v)
% (x,y,w) =  1.0e+08 *( 0.1369   -2.2259    0.0001)
% X = ( 7.1262e+03, 1.5750e+03) (u,v)
% (x,y,w) =  1.0e+06 *( -1.0538    3.3134    0.0017)
% Y = ( -309.7820, 1.5919e+03 ) (u,v)
% (x,y,w) =    1.0e+07 *( -0.4833    2.4834    0.0016)


