function [ best_model ] = myFRANSAC( points1, points2, n, k, t, verbose )

%% Detect surf features on both images
rng('default'); % Set random seed to default
tic;

numMatch = size(points1, 1);

%% The input to the algorithm is:
image1_points = points1;% Pixel locations in the first img
image1_points(:,3) = 1; % Add homogeneous coordinate

image2_points = points2;% Pixel locations in the second img
image2_points(:,3) = 1;

x_left = ones(n, 3); % Points we want to match
x_right = ones(n, 3); % Points to be matched against 

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
        x_left(j, :) = image1_points(rand_indices(j), :);
        x_right(j, :) = image2_points(rand_indices(j), :);
    end
    
    % Create A matrix using the data
    maybe_model = getFMatrix(x_left, x_right);
    
    % Check how good the transformation is with all the points
    consensus_set = 0;
    total_error = 0;
    for j = 1:numMatch
        % x1 * F * x2 = 0, that is a good F
        distError = abs(image1_points(j,:) * maybe_model * image2_points(j,:)');
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

ransac_time = toc;

if verbose
    fprintf('Ransac elapsed time %2.2f\n', ransac_time);
end

end

