function [ sift_indices, sift_descriptors, xind, yind, zind, sigma_vec, theta ] ...
    = mysift( imgPath, gaussians_range, reject_weak_points )
    
    if nargin < 3
        reject_weak_points = false;
    end
    
    img = imread(imgPath);

    %If image is not in gray scale then convert it
    if size(img, 3) > 1
        img = rgb2gray(img);
    end

    %Normalize image, pixels in range [0, 1]
    img = double(img)/ 255;
    %imshow(img);


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
        gmg(:,:,i) = real(fftshift(ifft2(fft2(img).*fft2(g1))));
    end

    %% FINDING MAXIMA AND MINIMA
    q = imregionalmax(jmg) | imregionalmin(jmg);

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

    %% REJECTING WEAK POINTS

    if reject_weak_points
        for i=1:length(xind)
            %Take 5x5 patches
            sub_mat_indx = [xind(i) - 2: xind(i) + 2];
            sub_mat_indy = [yind(i) - 2: yind(i) + 2];

            %Calculate partial derivatives with respect to x and y
            %using neighbour differences 
            sub_img = jmg(sub_mat_indx, sub_mat_indy, zind(i));
            dxright = conv2(sub_img, [-1, 1], 'same');
            dxleft = conv2(sub_img, [1, -1], 'same');
            dx = sqrt(dxright.^2 + dxleft.^2);

            dxright = conv2(dx, [-1, 1], 'same');
            dxleft = conv2(dx, [1, -1], 'same');
            dxx = sqrt(dxright.^2 + dxleft.^2);

            dyright = conv2(sub_img, [-1, 1]', 'same');
            dyleft = conv2(sub_img, [1, -1]', 'same');
            dy = sqrt(dyright.^2 + dyleft.^2);

            dyright = conv2(dy, [-1, 1]', 'same');
            dyleft = conv2(dy, [1, -1]', 'same');
            dyy = sqrt(dyright.^2 + dyleft.^2);

            dxyright = convn(dy, [-1, 1], 'same');
            dxyleft = convn(dy, [1, -1], 'same');
            dxy = sqrt(dxyright.^2 + dxyleft.^2);

            %Take the vale at the center -> the current pixel
            dx = dx(3,3);
            dy = dy(3,3);
            dxx = dxx(3,3);
            dyy = dyy(3,3);
            dxy = dxy(3,3);

            hessian = [dxx, dxy; dxy, dyy];

            % -inv(dxx) * dx = - dxx / dx
            extremum = - dxx / dx;

            d_extremum_val = sub_img(3,3) + 0.5 * dx * extremum;

            tr_h2 = (dxx + dyy)^2;
            det_h = dxx*dyy - dxy^2;

            r = 10;
            edge_threshold = (r + 1)^2 / r;

            %Mark to discard values with less than 0.03
            if d_extremum_val < 0.03
                xind(i) = -1;
                yind(i) = -1;
                zind(i) = -1;
            end

            if det_h <= 0 
                xind(i) = -1;
                yind(i) = -1;
                zind(i) = -1;            
            else
                tr_h_over_det_h = tr_h2 / det_h;
                if tr_h_over_det_h > edge_threshold
                    xind(i) = -1;
                    yind(i) = -1;
                    zind(i) = -1;  
                end
            end
        end

        %Delete all values marked with invalid indexes
        %If they were deleted inside the loop the indices would be wrong in
        %the next loop iteration
        xind = xind(xind~=-1);
        yind = yind(yind~=-1);
        zind = zind(zind~=-1);
    end

    %% ORIENTATION ASSIGMENT
    for i=1:length(xind)
        % sqrt( (L(x + 1, y) - L(x - 1, y))^2 + (L(x, y + 1) - L(x, y - 1))^2 )
        %patch index = [-8, 7; -8, 7] -> 16x16 patch
         strength(:,:,i) = ( (gmg(xind(i) - 7: xind(i) + 8, yind(i) - 8:yind(i) + 7, zind(i)) ...
            - gmg(xind(i) - 9:xind(i) + 6, yind(i) - 8:yind(i) + 7, zind(i))).^2 + ...
            (gmg(xind(i) - 8: xind(i) + 7, yind(i) - 7:yind(i) + 8, zind(i)) ...
            - gmg(xind(i) - 8:xind(i) + 7, yind(i) - 9:yind(i) + 6, zind(i))).^2 ).^0.5;

        % inv_tan( (L(x, y + 1) - L(x - 1, y)) / (L(x + 1, y) - L(x, y - 1)) )
        theta(:,:,i) = atand( ( gmg(xind(i) - 8: xind(i) + 7, yind(i) - 7:yind(i) + 8, zind(i) ) -  ...
             gmg(xind(i) - 9: xind(i) + 6, yind(i) - 8:yind(i) + 7, zind(i) ))  ./ ...
            (gmg(xind(i) - 7: xind(i) + 8, yind(i) - 8:yind(i) + 7, zind(i) ) - ...
            gmg(xind(i) - 8: xind(i) + 7, yind(i) - 9:yind(i) + 6, zind(i))) );    
    end


    %% DESCRIPTOR CALCULATION

    sift_descriptors = [];
    for i=1:length(xind)
        %Take 16x16 patch
        sub_mat_indx = [xind(i) - 7: xind(i) + 8];
        sub_mat_indy = [yind(i) - 7: yind(i) + 8];

        sub_img = jmg(sub_mat_indx, sub_mat_indy, zind(i));

        patch_angles = theta(:,:,i);
        patch_magnitudes = strength(:,:,i);

        magnitude_count = 0;
        point_descriptor = [];

        %Divide patch in 4 sub patches
        for j=1:4
            for k=1:4
                sub_patch_angles = patch_angles([1 + (j - 1) * 4:j * 4], [1 + (k - 1) * 4:k*4]  );
                sub_patch_magnitues = patch_magnitudes([1 + (j - 1) * 4:j * 4], [1 + (k - 1) * 4:k*4]  );
                %Do a histogram for each angle
                for alpha=0:45:359
                    for i1=1:4
                        for j1=1:4
                            %Count the point if within the current angle range
                            if sub_patch_angles(i1, j1) > (- 180 + alpha) && ...
                                    sub_patch_angles(i1, j1) < (-135 + alpha)
                                magnitude_count = magnitude_count + sub_patch_magnitues(i1,j1)*1.5;
                            end                  
                        end
                    end
                    point_descriptor = [point_descriptor magnitude_count];
                end
            end
        end
        sift_descriptors = [sift_descriptors; point_descriptor];
    end

    sift_indices = [yind'; xind'];
end

