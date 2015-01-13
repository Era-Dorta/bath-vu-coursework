function [ jmg ] = myDoGsspace( img, gaussians_range )
    n = size(img, 2);
    m = size(img, 1);
    [x , y] = meshgrid(linspace(-n/2, n/2, n), linspace(-m/2, m/2, m));

    %% CALCULATING THE GAUSSIANS
    %sigma_vec = 2.^[0:0.5:4];
    sigma_vec = 2.^gaussians_range;
    scale_size = length(sigma_vec);

    for i = 1:scale_size
        sigma = sigma_vec(i);

        h = x.^2 + y.^2;
        h = h / sigma^2;
        g1 = exp(-0.5*h);
        g1 = g1 / (2 * pi * sigma^2);

        sigma = 2*sigma;
        h = x.^2 + y.^2;
        h = h / sigma^2;
        g2 = exp(-0.5*h);
        g2 = g2 / (2 * pi * sigma^2);

        jmg(:,:,i) = real(fftshift(ifft2(fft2(img).*fft2(g2 - g1))));
    end
end

