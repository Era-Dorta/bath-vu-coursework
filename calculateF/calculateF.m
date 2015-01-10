close all;
clear all;

img1 = imreadgrey('images/cube_left.png');
img2 = imreadgrey('images/cube_right.png');

figure; imshow([img1,img2]); hold on
[h,w] = size(img1);

x_right = [217.5, 90.5; 268, 96.5; 321, 102.5; 190.5, 107.5; 243.5, 114.5; ...
    299.5, 121.5; 159, 127.5; 215.5, 135.5; 275, 144; ...
    132, 211; 189.5, 221.5; 250.5, 232.5; 140, 266.5; 195.5, 277.5; ...
    253.5, 289.5; 148.5, 316.5; 201, 329; 256.5, 341.5];

x_left = [322.5, 102.5; 374, 97; 425, 90.5; 341.5, 122; 399, 114.5; ...
    451, 108; 367, 144.5; 425, 136; 484.5, 127.5; ...
    391.5, 232.5; 451.5, 221.5; 509, 211; 387.5, 289.5; 445.5, 277.5; ...
    500.5, 265.5; 384.5, 341.5; 440, 329; 493, 316];

x_left = x_left';
x_right = x_right';


plot(x_left(1,:),x_left(2,:), 'r*'); hold on;
plot(x_right(1,:)+w,x_right(2,:), 'r*'); hold on;

for i = 1:18
    line([x_left(1,i),x_right(1,i)+w],[x_left(2,i),x_right(2,i)], 'Color',[.8 .1 .8]);
end


%% The input to the algorithm is:
image1_points = x_left';% Pixel locations in the first img
image1_points(:,3) = 1; % Add homogeneous coordinate

image2_points = x_right';% Pixel locations in the second img
image2_points(:,3) = 1;

%F1 = F_Norm8(x_left, x_right);

n = 8; %- the number of random points to pick every iteration in order to create the transform.
k = 5000; % - the number of iterations to run
t = 5; % - the threshold for the square distance for a point to be considered as a match
verbose = true; % true to display extra information

F = myFRANSAC(image1_points, image2_points, n, k, t, verbose);
