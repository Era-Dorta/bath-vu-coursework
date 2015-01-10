function [ A ] = makeA3dMatrix( x, u )
    A = zeros(12, 12);
    j = 1;
    for i=1:2:2*size(x, 1)
        A(i, 1:4) = -x(j,:);
        A(i, 9:12) = x(j, :) .* u(j, 1);
        A(i + 1, 5:8) = -x(j,:);
        A(i + 1, 9:12) = x(j, :) .* u(j, 2);        
        j = j + 1;
    end
end
