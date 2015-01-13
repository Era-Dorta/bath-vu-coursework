close all;
clear all;

img = imreadgrey('images/lena.jpg');
dog = myDoGsspace(img, [0:0.5:4]);

%% Plotting the result
figure;
numPiramid = size(dog, 3);
I2 = zeros(512,512,1,numPiramid);
for i=1:numPiramid
    I2(:,:,1,i) = dog(:,:,i);
end

q = imregionalmax(dog) | imregionalmin(dog);

%Clean up values too close to the edges
%In the first octave
q(:,:,1) = 0;
%In the last octave
q(:,:,size(q,3)) = 0;
%In the first nine raws
q(1:9,:,:) = 0;
%In the last nine raws
q(size(q,1) - 9:size(q,1),:,:) = 0;
%In the first nine cols
q(:,1:9,:) = 0;
%In the last nine cols
q(:,size(q,1) - 9:size(q,2),:) = 0;

%Get all the indices iqual to 1 in q
flat_indices = find(q);

%Map them to 3d indices
[xind,yind,zind] = ind2sub(size(q), flat_indices);

montage(I2, 'Size', [3,3]);
%hold on;
%plot(xind(1), yind(1), 'rx');
%hold off;