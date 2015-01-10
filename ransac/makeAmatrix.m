function [ A ] = makeAmatrix( x, u )
    A = zeros(8, 9);
    j = 1;
    for i=1:2:2*size(x, 1)
        A(i, 1:3) = -x(j,:);
        A(i, 7:9) = x(j, :) .* u(j, 1);
        A(i + 1, 4:6) = -x(j,:);
        A(i + 1, 7:9) = x(j, :) .* u(j, 2);        
        j = j + 1;
    end
end
