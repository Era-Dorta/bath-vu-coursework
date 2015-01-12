close all;
clear all;

%% Load the original and the modified image
%img1 = imreadgrey('images/sift_data/box.pgm');
%img2 = imreadgrey('images/sift_data/scene.pgm');

%img1 = imreadgrey('images/zhang_data/CalibIm4.tif');
%img2 = imreadgrey('images/zhang_data/CalibIm5.tif');

%img1 = imreadgrey('images/lena.jpg');
%img2 = imreadgrey('images/lena_scalrot.jpg');

img1 = imreadgrey('images/guitarLeft.png');
img2 = imreadgrey('images/guitarRight.png');

%img1 = imreadgrey('images/spaceConsoleLeftCut.png');
%img2 = imreadgrey('images/spaceConsoleRightCut.png');

n = 4; %- the number of random points to pick every iteration in order to create the transform.
k = 1000; % - the number of iterations to run
t = 5; % - the threshold for the square distance for a point to be considered as a match
verbose = true; % true to display extra information

aff_tr = mymatchRANSAC(img1, img2, n, k, t, verbose);

tform = affine2d(aff_tr);
resImg = imwarp(img1, tform);

%% Show results
figure; imshow(img1);
figure; imshow(img2); 
figure; imshow(resImg);
