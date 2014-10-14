function [ img ] = imreadgrey( imgPath )
    img = imread(imgPath);
    %If image is not in gray scale then convert it

    %If image is not in gray scale then convert it
    if size(img, 3) > 1
        img = rgb2gray(img);
    end

    %Normalize image, pixels in range [0, 1]
    img = double(img)/ 255;
end

