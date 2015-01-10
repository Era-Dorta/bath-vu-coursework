close all;
clear all;

load('leftCam.mat');
load('rightCam.mat');

simpleRecons = false;

if simpleRecons
    img1 = imreadgrey('images/cube_left.png');
    img2 = imreadgrey('images/cube_right.png');
    
    x_right = [217.5, 90.5; 268, 96.5; 321, 102.5; 190.5, 107.5; 243.5, 114.5; ...
        299.5, 121.5; 159, 127.5; 215.5, 135.5; 275, 144; ...
        132, 211; 189.5, 221.5; 250.5, 232.5; 140, 266.5; 195.5, 277.5; ...
        253.5, 289.5; 148.5, 316.5; 201, 329; 256.5, 341.5]';
    
    x_left = [322.5, 102.5; 374, 97; 425, 90.5; 341.5, 122; 399, 114.5; ...
        451, 108; 367, 144.5; 425, 136; 484.5, 127.5; ...
        391.5, 232.5; 451.5, 221.5; 509, 211; 387.5, 289.5; 445.5, 277.5; ...
        500.5, 265.5; 384.5, 341.5; 440, 329; 493, 316]';
else
    img1 = imreadgrey('images/car_left.png');
    img2 = imreadgrey('images/car_right.png');

    points1 = detectSURFFeatures(img1, 'MetricThreshold', 10);
    [features1, validPoints1] = extractFeatures(img1, points1);
    
    points2 = detectSURFFeatures(img2, 'MetricThreshold', 10);
    [features2, validPoints2] = extractFeatures(img2, points2);
    
    indexPairs = matchFeatures(features1,features2);
    numMatch = size(indexPairs, 1);
    x_left = validPoints1.Location(indexPairs(:, 1),:)';
    x_right = validPoints2.Location(indexPairs(:, 2),:)';
    
    figure; showMatchedFeatures(img1, img2, x_left', x_right');
end

X = Reconstruct(rightP, leftP, x_right, x_left);

figure;
plot3(X(1,:), X(2,:), X(3,:), 'r*');