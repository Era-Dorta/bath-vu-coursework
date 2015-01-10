function [ F ] = getFMatrix( x_left, x_right )
    n = size(x_left,1);
    % Create A matrix using the data
    A = [x_right(:,1).*x_left(:,1), x_right(:,1).*x_left(:, 2), ...
        x_right(:,1), x_right(:,2).*x_left(:,1), x_right(:,2).*x_left(:,2), ...
        x_right(:,2), x_left(:,1), x_left(:,2), ones(n,1)];
    % Solve the equations unsing SVD
    [~, ~, V] = svd(A, 0);
    
    % The affine matrix transformation is the last column of the V matrix
    % transposed
    F = reshape(V(:, end), [3, 3])';
    
    [U,D,V] = svd(F,0);
    D(3,3) = 0;
    F = U*D*V';
end

