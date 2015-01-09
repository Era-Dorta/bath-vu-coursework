function [ H ] = makeHmatrix( x, u )
    H = zeros(8, 9);
    j = 1;
    for i=1:2:2*size(x, 1)
        H(i, 1:3) = -x(j,:);
        H(i, 7:9) = x(j, :) .* u(j, 1);
        H(i + 1, 4:6) = -x(j,:);
        H(i + 1, 7:9) = x(j, :) .* u(j, 2);        
        j = j + 1;
    end
end
