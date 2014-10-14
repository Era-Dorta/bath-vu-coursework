close all;
clear all;

img0 = imreadgrey('lena.jpg');
img1 = imreadgrey('lena_rot.jpg');

points0 = detectSURFFeatures(img0);
[features0, validPoints0] = extractFeatures(img0, points0);

points1 = detectSURFFeatures(img1);
[features1, validPoints1] = extractFeatures(img1, points1);

% figure; imshow(img0); hold on;
% plot(validPoints0.selectStrongest(10),'showOrientation',true);
% 
% figure; imshow(img1); hold on;
% plot(validPoints1.selectStrongest(10),'showOrientation',true);

%Take the first x features from the points
numPoints = 10;
subPoints0 = validPoints0([1:numPoints]);
subFeatures0 = features0([1:numPoints], :);

%For each point in our subset of points calculate the distance in feature
%space to all the points in the second set
for i=1:numPoints
    for j=1:size(features1, 1)
        distances(i,j) = norm(subFeatures0(i, :) - features1(j, :));
    end
end

%Store insubPoints1 the points whose distance is closestto the ones in
%the patch we are looking for
subPoints1 = SURFPoints;
for i=1:numPoints
    [~, index] = min(distances(i, :));
    subFeatures1(i) = features1(index);
    subPoints1(i) = validPoints1(index);
end


% figure; imshow(img0); hold on;
% plot(subPoints0);
% 
% figure; imshow(img1); hold on;
% plot(subPoints1);

imgCenter = [size(img0, 1) / 2, size(img0, 2) / 2]; 
%The input to the algorithm is:
n = 3; %- the number of random points to pick every iteration in order to create the transform. I chose n = 3 in my implementation.
k = 100; % - the number of iterations to run
t = 50; % - the threshold for the square distance for a point to be considered as a match
d = 3; %- the number of points that need to be matched for the transform to be valid
image1_points = subPoints0.Location;
image2_points = subPoints1.Location; %- two arrays of the same size with points. 
%Assumes that image1_points[x] is best mapped to image2_points[x] accodring to the computed features.

best_model = [];
best_error = Inf;
best_angle = 0;
for i = 0:k
  rand_indices = randi([1,numPoints]);
  base_points = image1_points(rand_indices);
  input_points = image2_points(rand_indices);
  %TODO There could be more transformations or searching for a subimage 
  angle = randi([0,360]);
  maybe_model = rot2d(degtorad(angle)); %find best transform from input_points -> base_points

  consensus_set = 0;
  total_error = 0;
  for j = 1:numPoints
      image2p = image2_points(j, :);
      image1p = image1_points(j, :);
      %Translate the imgCenter to the origin, rotate, then translate back
      image1PointTrans = maybe_model * (image1_points(j, :) - imgCenter)' + imgCenter';
    distError = norm(image2_points(j, :) - image1PointTrans');
    if distError < t
      consensus_set = consensus_set + 1;
      total_error = total_error + distError;
    end
  end

  if consensus_set > d && total_error < best_error
    best_model = maybe_model;
    best_error = total_error;
    best_angle = angle;
  end
end

resImg = imrotate(img0, -best_angle);
disp(best_angle);

figure; imshow(img0); hold on;
figure; imshow(img1); hold on;
figure; imshow(resImg); hold on;
