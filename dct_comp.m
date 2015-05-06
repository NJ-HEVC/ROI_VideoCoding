function [reconsImage, PSNR]  = dct_comp(input_image, noOfcoeff_ROI, noOfcoeff_nonROI, bbox)
% clc
% clear
% tic
% input_image = imread('cameraman.tif');
% input_image = double(input_image);

% subplot(1,2,1);
% imshow(uint8(input_image));
% title('Original Image');

% noOfcoeff = input('Enter the no of Coeff to retain for compression [1-64] : ');
% noOfcoeff = 32;
[h,w] = size(input_image);

x_no_blocks = w/8;
y_no_blocks = h/8;

s =  zeros(8,8);
sd = zeros(8,8);

x_roi_start = bbox(1)/8 -1;
x_roi_end = (bbox(1) + bbox(3))/8 + 1;
y_roi_start = bbox(2)/8 -1;
y_roi_end = (bbox(2) + bbox(4))/8 + 1;

roi_count = 0;
non_count = 0;
for i = 1:y_no_blocks
    for j=1:x_no_blocks
        yoffset = (i-1)*8;
        xoffset = (j-1)*8;
        s(1:8,1:8) = input_image( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
        sd (1:8,1:8) =  s(1:8,1:8); %level shifted
        dcts = dct2(sd);
        
        if( (x_roi_start <= j) && (j<=x_roi_end) && (y_roi_start <= i) && (i<=y_roi_end))
            if (noOfcoeff_ROI == 64)
                mod_dcts = dcts;
            else
                [~, idx] = esort(abs(dcts));
                c = zeros(8,8);
                for k=1:noOfcoeff_ROI
                    n = idx(k)-1;
                    c( mod(n,8)+1 , floor(n/8) + 1) = 1;
                end
                mod_dcts = dcts.*c;
            end
            roi_count = roi_count + 1;
        else
            [~, idx] = esort(abs(dcts));
            c = zeros(8,8);
            for k=1:noOfcoeff_nonROI
                n = idx(k)-1;
                c( mod(n,8)+1 , floor(n/8) + 1) = 1;
            end
            mod_dcts = dcts.*c;
            non_count = non_count + 1;
        end
        dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = mod_dcts(1:8,1:8);
    end
end


%Reconstruction

% recdDctHat = zeros(w,h);
for i = 1:y_no_blocks
    for j=1:x_no_blocks
        yoffset = (i-1)*8;
        xoffset = (j-1)*8;
        recdDctHat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
        recdSd( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = idct2(recdDctHat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8));
    end
end

reconsImage = (recdSd);
% toc


% PSNR calculations
squaredErrorImage = (double(input_image) - double(reconsImage)) .^ 2;
mse = sum(sum(squaredErrorImage)) / (h * w);
PSNR = 10 * log10( 255^2 / mse);
% roi_count;
% non_count;

% subplot(1,2,2);
% imshow(uint8(reconsImage));
% title('Reconstructed Image');

end