close all;
clear all;

imgPath = 'lena.jpg';
[sift_indices, sift_descriptors] = mysift(imgPath, true);

%% Plotting the result
imshow(imread(imgPath));
hold on;
for i = 1:size(sift_indices, 2)
    plot(sift_indices(1, i), sift_indices(2, i), 'rx');
    %Plot the line
    %plot([yind(i), yind(i) + 2*sigma_vec(zind(i))*sin(theta(6,6,zind(i)  ))], ...
    %    [xind(i), xind(i) + 2*sigma_vec(zind(i))*cos(theta(6,6,zind(i) ))]);
    %Plot the circles
    %viscircles([yind(i), xind(i)], 2*sigma_vec(zind(i)), 'LineWidth',0.3);
end
hold off;
