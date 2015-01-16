close all;
clear all;

% To calibrate the camera click on the closest corner to the camera and
% then continue going clockwise

% 1 to calibrate the left camera, 2 to calibrate the right camera
camera_index = 2;

% True to used points that were previously input, or false to manually
% input new ones
useSavedPoints = true;

% Load images
img_v = {imreadgrey('images/cube_left.png'), imreadgrey('images/cube_right.png')};
img = img_v{camera_index};

figure; imshow(img); hold on;

if useSavedPoints
    input_p_v = {0,0};
    % 2D coordinates of the cube edges in camera space
    input_p_v{1} =  [325.5883,  402.1961,  1;
        258.8746,  279.5106,    1;
        249.8286,   92.9382,    1;
        446.5777,   69.1926,    1;
        573.7862,  141.5601,    1;
        534.7756,  350.1820,    1];
    
    input_p_v{2} = [315.4117,  402.7615,    1;
        105.6590,  350.1820,    1;
        67.2138,  142.1254,    1;
        193.8569,   69.1926,    1;
        391.7367,   91.8074,    1;
        382.6908,  277.2491,    1];
    
    input_p = input_p_v{camera_index};
else
    % Get six image calibration points from the user
    [x,y] = ginput(6);
    input_p = [x, y, ones(6,1)];
end

base_p_v = {0,0};

% 3D coordinates of the cube edges in world space, we asume x right, z up,
% y into the screen, and world origin to be centre of the cube bottom plane  
base_p_v{1} = [-2, -2, 0, 1; -2, 2, 0, 1; ...
    -2, 2, 4, 1; 2, 2, 4, 1; ...
    2, -2, 4, 1; 2, -2, 0, 1];

base_p_v{2} = [2, -2, 0, 1; -2, -2, 0, 1; ...
    -2, -2, 4, 1; -2, 2, 4, 1; ...
    2, 2, 4, 1; 2, 2, 0, 1];

base_p = base_p_v{camera_index};

% Construct A matrix from both points
A = makeA3dMatrix(base_p, input_p);

% Use SVD to solve A
[~, ~, V] = svd(A);

% P is in the last column of V, also normalize the value in 3,4
P = reshape(V(:, end), [4, 3])';
P = P / P(3,4);

% Test the points, by projecting them using P and drawing them on top of
% the image
for i=1:6
    testp = P*base_p(i,:)';
    testp = testp / testp(3);
    testp = testp(1:2);
    plot(input_p(i,1), input_p(i,2), 'ob');
    plot(testp(1), testp(2), 'xr');
end

hold off;

[K, R, t] = decomposeP(P);

% Camera position in 3D word space
c_v = {0,0};
c_v{1} = [-5, -10, 8];
c_v{2} = [5, -10, 8];
c = c_v{camera_index};

% An extra test it that t sould be equal to t = -R * c;
% t1 = -R * c';