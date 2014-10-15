close all;
clear all;

img1 = imreadgrey('lena.jpg');
img2 = imreadgrey('lena_rot.jpg');

points1 = detectSURFFeatures(img1);
[features1, validPoints1] = extractFeatures(img1, points1);

points2 = detectSURFFeatures(img2);
[features2, validPoints2] = extractFeatures(img2, points2);

% figure; imshow(img0); hold on;
% plot(validPoints0.selectStrongest(10),'showOrientation',true);
% 
% figure; imshow(img1); hold on;
% plot(validPoints1.selectStrongest(10),'showOrientation',true);

%Take the first x features from the points
numPoints1 = 4;
subPoints1 = validPoints1.selectStrongest(numPoints1);
for i=1:numPoints1
    for j=1:size(features1, 1)
        if subPoints1(i).Location == validPoints1(j).Location
            subFeatures1(i,:) = features1(i,:);
        end
    end
end

numPoints2 = validPoints2.Count;
% subPoints0 = validPoints0([1:numPoints]);
% subFeatures0 = features0([1:numPoints], :);
% 
% %For each point in our subset of points calculate the distance in feature
% %space to all the points in the second set
% for i=1:numPoints
%     for j=1:size(features1, 1)
%         distances(i,j) = norm(subFeatures0(i, :) - features1(j, :));
%     end
% end
% 
% %Store insubPoints1 the points whose distance is closestto the ones in
% %the patch we are looking for
% subPoints1 = SURFPoints;
% for i=1:numPoints
%     [~, index] = min(distances(i, :));
%     subFeatures1(i) = features1(index);
%     subPoints1(i) = validPoints1(index);
% end


% figure; imshow(img0); hold on;
% plot(subPoints0);
% 
% figure; imshow(img1); hold on;
% plot(subPoints1);

% imgCenter = [size(img0, 1) / 2, size(img0, 2) / 2]; 
%The input to the algorithm is:
n = 4; %- the number of random points to pick every iteration in order to create the transform.
k = 100; % - the number of iterations to run
t = 100; % - the threshold for the square distance for a point to be considered as a match
d = 0; %- the number of points that need to be matched for the transform to be valid
base_points = subPoints1.Location;
base_points(:,3) = 1;
image2_points = validPoints2.Location; %- two arrays of the same size with points.
%add homogeneus coordinate
image2_points(:,3) = 1;
input_points = ones(n, 3);
%Assumes that image1_points[x] is best mapped to image2_points[x] accodring to the computed features.

best_model = eye(3);
best_error = Inf;
best_angle = 0;
for i = 0:k
    %Generate random array of size n with unrepeated indices up to numPoints
    rand_indices = randperm(numPoints2, n);

    for j = 1:n
        input_points(j, :) = image2_points(rand_indices(j), :);
        input_features(j, :) = features2(j,:);
    end
    
    %Reorder input_points so that the are matched with base_points
    %according to distance, so closer points will go together
    input_points = reorderPoints(base_points, subFeatures1, input_points, input_features);
    %Compose a homography matrix using the data
    homographyMatrix = makeHomographyMatrix(base_points, input_points);
    %Solve the equations
    [~, ~, V] = svd(homographyMatrix);
    maybe_model = vec2mat(V(:, end), 3);
    
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

for i=1:size(img1,1)
    for j=1:size(img1,2)
        newIndex = best_model * [i,j,1]';
        newIndex = round(newIndex / newIndex(3));
        if(newIndex(1) >= 1 && newIndex(1) < 500 && newIndex(2) >= 1 && newIndex(2) < 500)
            resImg(newIndex(1), newIndex(2)) = img1(i,j);
        end
    end
end

figure; imshow(img1); hold on;
figure; imshow(img2); hold on;
figure; imshow(resImg); hold on;
