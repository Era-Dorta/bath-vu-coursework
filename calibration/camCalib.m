close all;
clear all;

%img = imreadgrey('images/cube_left.png');
img = imreadgrey('images/cube_right.png');
figure; imshow(img); hold on;

useSavedPoints = false;

if useSavedPoints
    input_p_left =  [325.5883,  402.1961,  1;
        258.8746,  279.5106,    1;
        249.8286,   92.9382,    1;
        446.5777,   69.1926,    1;
        573.7862,  141.5601,    1;
        534.7756,  350.1820,    1];
    
    input_p =    [315.4117,  402.7615,    1;
  105.6590,  350.1820,    1;
   67.2138,  142.1254,    1;
  193.8569,   69.1926,    1;
  391.7367,   91.8074,    1;
  382.6908,  277.2491,    1]
else
    % Get six image calibration points from the user
    [x,y] = ginput(6);
    input_p = [x, y, ones(6,1)];
end

% Predetermined 3d world position of the calibration points
base_p_left = [-2, -2, 0, 1; -2, 2, 0, 1; ...
    -2, 2, 4, 1; 2, 2, 4, 1; ...
    2, -2, 4, 1; 2, -2, 0, 1];

% Right points
base_p = [2, -2, 0, 1; -2, -2, 0, 1; ...
    -2, -2, 4, 1; -2, 2, 4, 1; ...
    2, 2, 4, 1; 2, 2, 0, 1];

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

[K, R, t] = decomposeP(P);

% Camera position in 3D word space
c = [-5, -10, 8];

% To test, t sould be equal to t = -R * c;
t1 = -R * c';