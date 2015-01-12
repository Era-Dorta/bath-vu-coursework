function [ best_model ] = mymatchRANSAC( img1, img2, n, k, t, verbose )

%% Detect surf features on both images
rng('default'); % Set random seed to default
tic;

points1 = detectSURFFeatures(img1, 'MetricThreshold', 10);
[features1, validPoints1] = extractFeatures(img1, points1);

points2 = detectSURFFeatures(img2, 'MetricThreshold', 10);
[features2, validPoints2] = extractFeatures(img2, points2);

% Match the features, if I were to do this myself, I would calculate the
% distance in feature space from all points in image1 to all points in
% image2. Then the point in image2 assigned to a point in image1 would the
% one with the shortest distance.
indexPairs = matchFeatures(features1,features2, 'MaxRatio', 0.8);
numMatch = size(indexPairs, 1);
matchedPoints1 = validPoints1(indexPairs(:, 1));
matchedPoints2 = validPoints2(indexPairs(:, 2));

figure; showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2);

%% The input to the algorithm is:
image1_points = matchedPoints1.Location;% Pixel locations in the first img
image1_points(:,3) = 1; % Add homogeneous coordinate

image2_points = matchedPoints2.Location;% Pixel locations in the second img
image2_points(:,3) = 1;

base_points = ones(n, 3); % Points we want to match
input_points = ones(n, 3); % Points to be matched against

best_model = eye(3);
best_error = Inf;
prev_consensus = 0; % Number of inliers in the previous best model

%% Main loop
for i = 0:k
    % Take n random points from the first img and their matches in the
    % second image
    
    % Generate random array of size n with unrepeated indices up to
    % numMatch
    rand_indices = randperm(numMatch, n);
    
    for j = 1:n
        base_points(j, :) = image1_points(rand_indices(j), :);
        input_points(j, :) = image2_points(rand_indices(j), :);
    end
    
    % Create A matrix using the data
    A = makeAmatrix(base_points, input_points);
    
    % Solve the equations unsing SVD
    [~, ~, V] = svd(A);
    
    % The affine matrix transformation is the last column of the V matrix
    % transposed
    maybe_model = reshape(V(:, end), [3, 3])';
    
    % Check how good the transformation is with all the points
    consensus_set = 0;
    total_error = 0;
    for j = 1:numMatch
        % Transform the point in image1 using the model, and check how far
        % they end up from their matches in image2
        image1PointTrans = maybe_model * image1_points(j, :)';
        %Make sure the last coordinate is homogeneus
        image1PointTrans = image1PointTrans / image1PointTrans(3);
        distError = norm(image2_points(j, :) - image1PointTrans');
        if distError < t
            consensus_set = consensus_set + 1;
            total_error = total_error + distError;
        end
    end
    
    % Save this transformation if it includes more points in the consensus
    % or the same number of points but with less error
    if consensus_set >= prev_consensus
        if consensus_set > prev_consensus
            if verbose
                fprintf('Improving the model, points match %d, prev mean error %2.2f, current mean error %2.2f\n', ...
                    consensus_set, best_error/prev_consensus, total_error/consensus_set);
            end
            best_model = maybe_model;
            best_error = total_error;
            prev_consensus = consensus_set;
        else if total_error < best_error
                if verbose
                    fprintf('Improving the model, points match %d, prev mean error %2.2f, current mean error %2.2f\n', ...
                        consensus_set, best_error/prev_consensus, total_error/consensus_set);
                end
                best_model = maybe_model;
                best_error = total_error;
                prev_consensus = consensus_set;
            end
        end
    end
end

%% Convert the model into an affine transformation matrix

% Force 3,3 element to be 1
best_model = best_model / best_model(3,3);

% Force bottom two values to be 0, they should already be close to zero but
% they are not, due to numerical errors in the homography calculation and 
% in the previous normalization step
best_model(3,1:2) = 0;

% Matlab affine transformation matrices are transposed, [0, 0, 1] in the   
% last column instead of in the last row
best_model = best_model';

ransac_time = toc;

if verbose
    fprintf('Ransac elapsed time %2.2f\n', ransac_time);
end

end

