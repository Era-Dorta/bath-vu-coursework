close all;
clear all;

%% Load the original and the modified image
img1 = imreadgrey('lena.jpg');
img2 = imreadgrey('lena_rot.jpg');

%% Detect surf features on both images
points1 = detectSURFFeatures(img1);
[features1, validPoints1] = extractFeatures(img1, points1);

points2 = detectSURFFeatures(img2);
[features2, validPoints2] = extractFeatures(img2, points2);

%Show the strongest 10 surf points in each image
% figure; imshow(img1); hold on;
% plot(validPoints1.selectStrongest(10),'showOrientation',true);
% 
% figure; imshow(img2); hold on;
% plot(validPoints2.selectStrongest(10),'showOrientation',true);

%Take the numPoints1 strongest points from the first img
numPoints1 = 4;
subPoints1 = validPoints1.selectStrongest(numPoints1);
for i=1:numPoints1
    for j=1:size(features1, 1)
        %Location has the actual pixel indices
        if subPoints1(i).Location == validPoints1(j).Location
            subFeatures1(i,:) = features1(i,:);
        end
    end
end

numPoints2 = validPoints2.Count;

% figure; imshow(img1); hold on;
% plot(subPoints1);
 
%% The input to the algorithm is:
n = 4; %- the number of random points to pick every iteration in order to create the transform.
k = 100; % - the number of iterations to run
t = 50; % - the threshold for the square distance for a point to be considered as a match
d = 3; %- the number of points that need to be matched for the transform to be valid


base_points = subPoints1.Location; %Points we want to match
%add homogeneus coordinate
base_points(:,3) = 1;

image2_points = validPoints2.Location;%Points in the second img
image2_points(:,3) = 1;

input_points = ones(n, 3); %Points to be matched against

best_model = eye(3);
best_error = Inf;
best_angle = 0;

%% Main loop
for i = 0:k
    %Take n random points from the second img
    
    %Generate random array of size n with unrepeated indices up to
    %numPoints2
    rand_indices = randperm(numPoints2, n);

    for j = 1:n
        input_points(j, :) = image2_points(rand_indices(j), :);
        input_features(j, :) = features2(j,:);
    end
    
    %Reorder input_points so that the are matched with base_points
    %according to distance, so we will match first base_points with the
    %first input_points, second with second, etc
    input_points = reorderPoints(base_points, subFeatures1, input_points, input_features);
    
    %Create a homography matrix using the data
    homographyMatrix = makeHomographyMatrix(base_points, input_points);
    
    %Solve the equations unsing SVD
    [~, ~, V] = svd(homographyMatrix);
    
    %The affine matrix transformation is the last column of the V matrix
    maybe_model = vec2mat(V(:, end), 3);
    %The transformation does not correctly transform from img1 to img2
    
    %This should check how good the random points match the original points
    %so all this code is actually wrong
    consensus_set = 0;
    total_error = 0;
    for j = 1:numPoints1
        image2p = image2_points(j, :);
        image1p = base_points(j, :);
        %Transform the point using the model and check how far it is from
        %the point in img2
        image1PointTrans = maybe_model * image1p';
        image1PointTrans = image1PointTrans / image1PointTrans(3);
        distError = norm(image2p - image1PointTrans');
        if distError < t
            consensus_set = consensus_set + 1;
            total_error = total_error + distError;
        end
    end

    if consensus_set > d && total_error < best_error
        best_model = maybe_model;
        best_error = total_error;
    end
end

%% Create a new image applying the transformation to the first img
for i=1:size(img1,1)
    for j=1:size(img1,2)
        newIndex = best_model * [i,j,1]';
        newIndex = round(newIndex / newIndex(3));
        if(newIndex(1) >= 1 && newIndex(1) < 500 && newIndex(2) >= 1 && newIndex(2) < 500)
            resImg(newIndex(1), newIndex(2)) = img1(i,j);
        end
    end
end

%% Show results
figure; imshow(img1); hold on;
figure; imshow(img2); hold on;
figure; imshow(resImg); hold on;
