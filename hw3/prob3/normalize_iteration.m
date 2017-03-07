function [ x1n,y1n,x2n,y2n,T,Tnew ] = normalize_iteration( c1,r1,c2,r2,matches,pts_8 )
% normalizes the coordinates for a normalize 8 point algorithm
% (c) Steve Macenski 2017

    stdim1 = [(c1(pts_8(:,1)) - mean(c1(pts_8(:,1)))).^2, (r1(pts_8(:,1)) - mean(r1(pts_8(:,1)))).^2];
    stdim2 = [(c2(pts_8(:,2)) - mean(c2(pts_8(:,2)))).^2, (r2(pts_8(:,2)) - mean(r2(pts_8(:,2)))).^2];
    scale1 = sqrt(2)  /   std(sqrt(sum(stdim1,1))); %scale so that std=sqrt(2)
    scale2 = sqrt(2)  /   std(sqrt(sum(stdim2,1))); %TODO 2? 

    T    =  [scale1,0, -scale1*mean(c1((pts_8(:,1)))) ; 0,scale1, -scale1*mean(r1((pts_8(:,1)))) ; 0,0,1];
    Tnew =  [scale2,0, -scale2*mean(c2((pts_8(:,2)))) ; 0,scale2, -scale2*mean(r2((pts_8(:,2)))) ; 0,0,1];

    x1n = stdim1(:,1)*scale1;
    y1n = stdim1(:,2)*scale1;
    x2n = stdim2(:,1)*scale2;
    y2n = stdim2(:,2)*scale2;
end

