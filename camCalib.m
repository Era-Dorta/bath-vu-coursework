close all;
clear all;

%figure; imshow(imread('images/cubeInstructions.png'));
img = imreadgrey('images/cube_left.png');
figure; imshow(img); hold on;

useSavedPoints = true;

if useSavedPoints
    input_p =  [325.5883,  402.1961,  1;
        258.8746,  279.5106,    1;
        249.8286,   92.9382,    1;
        446.5777,   69.1926,    1;
        573.7862,  141.5601,    1;
        534.7756,  350.1820,    1];
else
    % Get six image calibration points from the user
    [x,y] = ginput(6);
    input_p = [x, y, ones(6,1)];
end

% Predetermined 3d world position of the calibration points
base_p = [-2, -2, 0, 1; -2, 2, 0, 1; ...
    -2, 2, 4, 1; 2, 2, 4, 1; ...
    2, -2, 4, 1; 2, -2, 0, 1];

% Construct A matrix from both points
A = makeA3dMatrix(base_p, input_p);

% Use SVD to solve A
[~, ~, V] = svd(A);

% P is in the last column of V, also normalize the value in 3,4
P = reshape(V(:, end), [4, 3])';
P = P / P(3,4);

% Test the points
for i=1:6
    testp = P*base_p(i,:)';
    testp = testp / testp(3);
    testp = testp(1:2);
    plot(input_p(i,1), input_p(i,2), 'ob');
    plot(testp(1), testp(2), 'xr');
end

hold off;

% Camera position in 3D word space
c = [-5, 10, -3];

