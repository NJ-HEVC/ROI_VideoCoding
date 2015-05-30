%Jpeg Compression and Decompression

clc
clear

%  input_image = imread('img1.tif');
input_image = imread('cameraman.tif');
input_image = double(input_image);
subplot(1,2,1);
imshow(uint8(input_image));
title('Original Image');

noOfcoeff = input('Enter the no of Coeff to retain for compression [1-64] : ');

% for noOfcoeff=1:64

[h,w] = size(input_image);

x_no_blocks = w/8;
y_no_blocks = h/8;
% x_no_blocks =1;
% y_no_blocks =2;
% qmat = [16 11 10 16 24 40 51 61;
%         12 12 14 19 26 58 60 55;
%         14 13 16 24 40 57 69 56;    
%         14 17 22 29 51 87 80 62;
%         18 22 37 56 68 109 103 77;
%         24 35 55 64 81 104 113 92;
%         49 64 78 87 103 121 120 101;
%         72 92 95 98 112 100 103 99 ];

    s =  zeros(8,8);
    sd = zeros(8,8);
    dcts = zeros(8,8);
%   dcthat = zeros(w,h);
    
for i = 1:y_no_blocks
    for j=1:x_no_blocks
         yoffset = (i-1)*8;
         xoffset = (j-1)*8;
         s(1:8,1:8) = input_image( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
         sd (1:8,1:8) =  s(1:8,1:8); %level shifted
         dcts = dct2(sd);         
         %dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = dcts./qmat(1:8,1:8);
         [sorted_dct, idx] = esort(abs(dcts));
         c = zeros(8,8);
        for k=1:noOfcoeff
            n = idx(k)-1;
            c( mod(n,8)+1 , floor(n/8) + 1) = 1;
        end
        
        
        
        mod_dcts = dcts.*c;
        dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = mod_dcts(1:8,1:8);
    end
end


%Reconstruction


% recdDctHat = zeros(w,h); 
for i = 1:y_no_blocks
    for j=1:x_no_blocks
         yoffset = (i-1)*8;
         xoffset = (j-1)*8;
        % recdDctHat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8).*qmat(1:8,1:8);
        recdDctHat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
        recdSd( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = idct2(recdDctHat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8));
    end
end

reconsImage = (recdSd);

subplot(1,2,2);
imshow(uint8(reconsImage));
title('Reconstructed Image');

MSE = sqrt(sum(sum( (abs(reconsImage-input_image)).^2 ))/(h*w));
rms(noOfcoeff) = MSE;
% end
% figure;
% plot(rms,noOfcoeff);
% ylabel('RMSE');
% xlabel('Retained Coefficients');