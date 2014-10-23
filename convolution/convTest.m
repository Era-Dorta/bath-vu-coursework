close all;
clear all;

img1 = imreadgrey('lena.jpg');
k = 1/9 * ones(3,3);

t1 = cputime;
outI1 = conv2(img1, k, 'valid');
t1 = cputime - t1;

t2 = cputime;
outI2 = myconv(img1, k);
t2 = cputime - t2;

figure; imshow(outI1);
figure; imshow(outI2);

error = sumsqr(outI1 - outI2);
fprintf( 'Error in myconv is: %f \n', error );

t3 = cputime;
out3 = myconvFF(img1, k);
t3 = cputime - t3;

figure; imshow(out3);

outI1 = conv2(img1, k, 'same');
error = sumsqr(outI1 - out3);
fprintf( 'Error in fft is: %f \n', error );

fprintf( 'Time conv2: %f, myconv: %f, myconvFF: %f \n', t1, t2, t3 );