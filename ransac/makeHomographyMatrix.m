function [ resMatrix ] = makeHomographyMatrix( x, u )
    resMatrix = zeros(8, 9);
    j = 1;
    for i=1:2:2*size(x, 1)
        resMatrix(i, 1:3) = -x(j,:);
        resMatrix(i, 7:9) = x(j, :) .* u(j, 1);
        resMatrix(i + 1, 4:6) = -x(j,:);
        resMatrix(i + 1, 7:9) = x(j, :) .* u(j, 2);        
        j = j + 1;
    end
end
