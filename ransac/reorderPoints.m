function [ resPoints2 ] = reorderPoints( points1, features1, points2, features2 )
    %For each point in our subset of points calculate the distance in feature
    %space to all the points in the second set
    for i=1:size(points1, 1)
        for j=1:size(features1, 1)
            distances(i,j) = norm(features1(i, :) - features2(j, :));
        end
    end

    for i=1:size(points1, 1)
        [~, index] = min(distances(i, :));
        resPoints2(i, :) = points2(index, :);
        distances(:, index) = Inf;
    end 
end

