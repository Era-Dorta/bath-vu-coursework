function [X] = reconstruct(P1, P2, x1, x2)
% Reconstruct - computes 3D points given two projection matrices
% and corresponding image points
%
% Input:
%           P1 - 3x4 projection matrix 1
%           P2 - 3x4 projection matrix 2
%           x1 - 2xn points in image 1
%           x2 - 2xn points in image 2
%
% Output:
%           X - 4xn point in space

n = size(x1, 2); % number of points

X = zeros(4,n);

for i = 1:n
    A = [x1(1,i) * P1(3,:) - P1(1,:);
        x1(2,i) * P1(3,:) - P1(2,:);
        x2(1,i) * P2(3,:) - P2(1,:);
        x2(2,i) * P2(3,:) - P2(2,:);
        ];
    
    [~,~,V] = svd(A);
    
    X(:, i) = V(:,end)/V(end,end);
end

end

