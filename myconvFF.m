function [ outI ] = myconvFF( I, kernel )
    ffk = fft2(kernel, size(I, 1), size(I, 2));
    outI = real(ifft2(fft2(I).*ffk));
end



