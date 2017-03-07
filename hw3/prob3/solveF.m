function [ F ] = solveF( x1n,y1n,x2n,y2n,T,Tnew )
% uses linear equations and SVD to find the denormalized F
% (c) Steve Macenski 2017

    % write system of linear eqns
    A = zeros(8,9);
    for i = 1:8
        A(i,:)  = [x1n(i)*x2n(i),    x1n(i)*y2n(i),    x1n(i),    y1n(i)*x2n(i), ...
                   y1n(i)*y2n(i),    y1n(i),    x2n(i),    y2n(i),    1];
    end

    % solve using SVD
    [U, S, V] = svd(A);
    f = V(:, end);
    Ftemp = reshape(f, [3 3])';

    [U, S, V] = svd(Ftemp);
    S(3,3) = 0; %enforce constraint det(F)=0;
    F = U*S*V';

    % denormalize
    F = Tnew'*F*T;
    F = F ./norm(F);
end

