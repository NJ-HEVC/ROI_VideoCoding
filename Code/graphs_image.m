%ROI based integer transform & DCT for single image
% Working - check for different roi, non roi scale
close all;
clear;
clc;

load table;
% load intra_quant_mat;


iteration = 0;
for Scale_ROI = 0.1 : 0.05: 1
%Integer transform - Scaling factors
QP_ROI = 25; %25-44
QP_NON_ROI = 48;  %25-44
transBlockSize = 4;

iteration = iteration+1;

%DCT - Scaling factors
% Scale_ROI = 0.48;   %0-1
Scale_nonROI = 0.232;    %0-1  | 0.01 is very bad |  
QP_Scale = 4 ; %Step size


OriginalFrame = rgb2gray((imread('librarypic.bmp')));
% imshow(OriginalFrame); title('Original Image');


[sizex,sizey] = size(OriginalFrame);

% bbox = [138,6,170,240]; % videochat pic
bbox = [153,17,160,209]; % librarypic

% figure;
% roi_img = insertShape(OriginalFrame,'rectangle',bbox);
% imshow(roi_img); title('Original Image with ROI');
%Integer transform based
[imgI_Reconstructed, entropy_ch1_IT] = roi_tranform_quantization(double(OriginalFrame), QP_ROI, QP_NON_ROI, bbox, transBlockSize);
% figure; imshow(uint8(imgI_Reconstructed)); title('Integer Tranform based Compression');

%DCT based
[compOut, ch1PSNR, entropy_ch1_dct]  = dct_comp((OriginalFrame),Scale_ROI, Scale_nonROI,bbox,QP_Scale);

% figure;
% imshow(uint8(compOut)); title('DCT based Compression');

Originalbits(iteration)= entropy(uint8(OriginalFrame)) * sizex *sizey /1024;
DCT_Bits(iteration) = (entropy_ch1_dct)* sizex *sizey /1024;
IT_Bits(iteration) = (entropy_ch1_IT)* sizex *sizey /1024;

[ROI_psnr_DCT(iteration), nonROI_psnr_DCT(iteration), Total_psnr_DCT(iteration)] = my_find_psnr(OriginalFrame, compOut, bbox);
[ROI_psnr_IT(iteration), nonROI_psnr_IT(iteration), Total_psnr_IT(iteration)] = my_find_psnr(OriginalFrame, imgI_Reconstructed, bbox);

end


plot(DCT_Bits./Originalbits); title('DCT : Compression ratio vs ROI parameter');xlabel('ROI Scale'); ylabel('Compression Ratio');
figure;plot(ROI_psnr_DCT); title('DCT : ROI PSNR vs ROI parameter');xlabel('ROI Scale'); ylabel('ROI PSNR');





% 
% sprintf(' IT_kb = %d, DCT_kb = %d,  IT_Comp=%f, DCT_comp = %f',IT_Bits,DCT_Bits,IT_Bits/Originalbits, DCT_Bits/Originalbits)
% 
% 
% sprintf('IT :ROI_psnr:%f  nonROI_psnr:%f Total_psnr:%f',ROI_psnr_IT,nonROI_psnr_IT,Total_psnr_IT)
% sprintf('DCT :ROI_psnr:%f  nonROI_psnr:%f Total_psnr:%f',ROI_psnr_DCT,nonROI_psnr_DCT,Total_psnr_DCT)