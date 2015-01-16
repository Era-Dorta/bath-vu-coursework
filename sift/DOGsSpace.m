close all;
clear all;

img = imreadgrey('images/lena.jpg');
h = size(img, 1);
w = size(img, 2);

% Vector with the sigma values for the DoG space
scale_sigmas = [0:0.5:4];
DoG = myDoGsspace(img, scale_sigmas);

%% Show the result
numPiramid = size(DoG, 3);

% Create a 4D data variable for the montage function
I2 = zeros(h, w, 1, numPiramid);
for i=1:numPiramid
    I2(:,:,1,i) = DoG(:,:,i);
end

% Find the extrema points
q = imregionalmax(DoG) | imregionalmin(DoG);

% Clean up values too close to the edges
% In the first octave
q(:,:,1) = 0;
% In the last octave
q(:,:,end) = 0;
% In the first nine raws
q(1:9,:,:) = 0;
% In the last nine raws
q(size(q,1) - 9:size(q,1),:,:) = 0;
% In the first nine cols
q(:,1:9,:) = 0;
% In the last nine cols
q(:,size(q,1) - 9:size(q,2),:) = 0;

% Get all the indices iqual to 1 in q
flat_indices = find(q);

% Map them to 3d indices
[xind,yind,zind] = ind2sub(size(q), flat_indices);

% Makes easier to calculate 2D positions
zind = zind - 1;

% Calculate the montage size to be square
mont_size = ceil(sqrt(numPiramid));
figure;
montage(I2, 'Size', [mont_size, mont_size]);

hold on;
plot(yind + mod(zind,mont_size)*w, xind + floor(zind/mont_size)*h, 'rx');
hold off;