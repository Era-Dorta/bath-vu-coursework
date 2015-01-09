close all;
clear all;

%% Load the original and the modified image
img1 = imreadgrey('lena.jpg');
img2 = imreadgrey('lena_scalrot.jpg');

n = 4; %- the number of random points to pick every iteration in order to create the transform.
k = 1000; % - the number of iterations to run
t = 10; % - the threshold for the square distance for a point to be considered as a match
d = 8; %- the number of points that need to be matched for the transform to be valid
verbose = true; % true to display extra information

aff_tr = mymatchRANSAC(img1, img2, n, k, t, d, verbose);

tform = affine2d(aff_tr);
resImg = imwarp(img1, tform);

%% Show results
figure; imshow(img1); hold on;
figure; imshow(img2); hold on;
figure; imshow(resImg); hold on;
