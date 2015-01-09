function [ H ] = makeH3dMatrix( x, u )
    H = zeros(12, 12);
    j = 1;
    for i=1:2:2*size(x, 1)
        H(i, 1:4) = -x(j,:);
        H(i, 9:12) = x(j, :) .* u(j, 1);
        H(i + 1, 5:8) = -x(j,:);
        H(i + 1, 9:12) = x(j, :) .* u(j, 2);        
        j = j + 1;
    end
end
