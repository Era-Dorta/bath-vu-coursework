close all;
clear all;

img1 = imreadgrey('lena.jpg');
k = 1/9 * ones(3,3);

outI1 = conv2(img1, k, 'valid');
outI2 = myconv(img1, k);

figure; imshow(outI1);
figure; imshow(outI2);

error = sumsqr(outI1 - outI2);
fprintf( 'Error in myconv is: %f \n', error );

out3 = myconvFF(img1, k);

figure; imshow(out3);

outI1 = conv2(img1, k, 'same');
error = sumsqr(outI1 - out3);
fprintf( 'Error in fft is: %f \n', error );