function [ best_model ] = mymatchRANSAC( img1, img2, numMatch, n, k, t, d, verbose )

%% Detect surf features on both images
rng('default'); %Set random seed to default
tic;

points1 = detectSURFFeatures(img1);
[~, validPoints1] = extractFeatures(img1, points1);

points2 = detectSURFFeatures(img2);
[~, validPoints2] = extractFeatures(img2, points2);

%Show the strongest 10 surf points in each image
% figure; imshow(img1); hold on;
% plot(validPoints1.selectStrongest(10),'showOrientation',true);
% 
% figure; imshow(img2); hold on;
% plot(validPoints2.selectStrongest(10),'showOrientation',true);

%Take the matchPoints strongest points from the first and the second img
subPoints1 = validPoints1.selectStrongest(numMatch);
subPoints2 = validPoints2.selectStrongest(numMatch);

%% The input to the algorithm is:
image1_points = subPoints1.Location;%Points in the first img
image1_points(:,3) = 1;

image2_points = subPoints2.Location;%Points in the second img
image2_points(:,3) = 1;

base_points = ones(n, 3); %Points we want to match
input_points = ones(n, 3); %Points to be matched against

best_model = eye(3);
best_error = Inf;

%% Main loop
for i = 0:k
    %Take n random points from the first and the second img
    
    %Generate random array of size n with unrepeated indices up to
    %numPoints2
    rand_indices1 = randperm(numMatch, n);
    rand_indices2 = randperm(numMatch, n);

    for j = 1:n
        base_points(j, :) = image1_points(rand_indices1(j), :);
        input_points(j, :) = image2_points(rand_indices2(j), :);
    end
    
    %Create a homography matrix using the data
    homographyMatrix = makeHomographyMatrix(base_points, input_points);
    
    %Solve the equations unsing SVD
    [~, ~, V] = svd(homographyMatrix);
    
    %The affine matrix transformation is the last column of the V matrix
    %transposed
    maybe_model = reshape(V(:, end), [3, 3]);
    maybe_model = maybe_model';
    
    %This checks how good the random points match the original points
    %so all this code is actually wrong
    consensus_set = 0;
    total_error = 0;
    for j = 1:numMatch
        image1p = image1_points(j, :);
        image2p = image2_points(j, :);
        %Transform the point using the model and check how far it is from
        %the point in img2
        image1PointTrans = maybe_model * image1p';
        %Make sure the last coordinate is homogeneus
        image1PointTrans = image1PointTrans / image1PointTrans(3);
        distError = norm(image2p - image1PointTrans');
        if distError < t
            consensus_set = consensus_set + 1;
            total_error = total_error + distError;
        end
    end

    if consensus_set >= d && total_error < best_error
        if verbose
            fprintf('Improving the model, points match %d, prev error %2.2f, current error %2.2f\n', ...
                consensus_set, best_error, total_error);
        end
        best_model = maybe_model;
        best_error = total_error;
    end
end

%% Create a new image applying the transformation to the first img
% for i=1:size(img1,1)
%     for j=1:size(img1,2)
%         newIndex = best_model * [i,j,1]';
%         newIndex = round(newIndex / newIndex(3));
%         if(newIndex(1) >= 1 && newIndex(1) < 500 && newIndex(2) >= 1 && newIndex(2) < 500)
%             resImg(newIndex(1), newIndex(2)) = img1(i,j);
%         end
%     end
% end

%Convert the model into an affine transformation matrix

%3,3 element has to be 1
best_model = best_model / best_model(3,3);

%Make sure bottom two values are 0, this step introduces rounding errors
best_model(3,1:2) = 0;

%Matlab requires the last column, not the last row to be the one with the
%zeros, so transpose the matrix
best_model = best_model';

ransac_time = toc;

if verbose
    fprintf('Ransac elapsed time %2.2f\n', ransac_time);
end

end

