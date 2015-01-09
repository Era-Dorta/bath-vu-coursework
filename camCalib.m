close all;
clear all;

figure; imshow(imread('images/cubeInstructions.png'));
img = imreadgrey('images/calibCube.png');
figure; imshow(img);

% Get six image calibration points from the user
[x,y] = ginput(6);

input_p = [x, y, ones(6,1)];

% Predetermined 3d world position of the calibration points
base_p = [0, 1, 3, 1; 0, 1, 1, 1; ...
                3, 4, 3, 1; 3, 4, 1, 1; ...
                1, 1, 0, 1; 3, 1, 0, 1];
            
% Construct H matrix from both points
H = makeH3dMatrix(base_p, input_p);

% Use SVD to solve H
[~, ~, V] = svd(H);

% P is in the last column of V, also normalize the value in 3,4
P = reshape(V(:, end), [4, 3])';
P = P / P(3,4); 