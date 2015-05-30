%ROI based integer transform & DCT for single image
% Working - check for different roi, non roi scale
close all;
clear;
clc;

load table;
% load intra_quant_mat;

%DCT - Scaling factor
Scale_ROI = 1.5;   %0-1
Scale_nonROI = 0.1;    %0-1  | 0.01 is very bad |  
QP_Scale = 4 ; %Step size

%Integer transform
QP_ROI = 20; %25-44
QP_NON_ROI = 35;  %25-44
transBlockSize = 4;


OriginalFrame = ((imread('videochat.bmp')));
image(OriginalFrame); title('Original Image');
[sizex,sizey] = size(OriginalFrame);

bbox = [86,40,160,160];
%Integer transform based
[imgI_Reconstructed(:,:,1), entropy_ch1_IT] = roi_tranform_quantization(double(OriginalFrame(:,:,1)), QP_ROI, QP_NON_ROI, bbox, transBlockSize);
[imgI_Reconstructed(:,:,2), entropy_ch2_IT] = roi_tranform_quantization(double(OriginalFrame(:,:,2)), QP_ROI, QP_NON_ROI, bbox, transBlockSize);
[imgI_Reconstructed(:,:,3), entropy_ch3_IT] = roi_tranform_quantization(double(OriginalFrame(:,:,3)), QP_ROI, QP_NON_ROI, bbox, transBlockSize);
figure; image(uint8(imgI_Reconstructed)); title('Integer Tranform Compressed');

%DCT based
[compOut(:,:,1), ch1PSNR, entropy_ch1_dct]  = dct_comp((OriginalFrame(:,:,1)),Scale_ROI, Scale_nonROI,bbox,QP_Scale);
[compOut(:,:,2), ch2PSNR, entropy_ch2_dct]  = dct_comp((OriginalFrame(:,:,2)),Scale_ROI, Scale_nonROI,bbox,QP_Scale);
[compOut(:,:,3), ch3PSNR, entropy_ch3_dct]  = dct_comp((OriginalFrame(:,:,3)),Scale_ROI, Scale_nonROI,bbox,QP_Scale);

figure;
image(uint8(compOut)); title('DCT Compressed');

DCT_Bits = (entropy_ch1_dct + entropy_ch2_dct + entropy_ch3_dct)* sizex *sizey;
IT_Bits = (entropy_ch1_IT + entropy_ch2_IT + entropy_ch3_IT)* sizex *sizey;

[ROI_psnr_DCT, nonROI_psnr_DCT, Total_psnr_DCT] = my_find_psnr(OriginalFrame, compOut, bbox);
[ROI_psnr_IT, nonROI_psnr_IT, Total_psnr_IT] = my_find_psnr(OriginalFrame, imgI_Reconstructed, bbox);

sprintf('DCT : Bits:%d  ROI_psnr:%f  nonROI_psnr:%f Total_psnr:%f',DCT_Bits,ROI_psnr_DCT,nonROI_psnr_DCT,Total_psnr_DCT)
sprintf('IT : Bits:%d  ROI_psnr:%f  nonROI_psnr:%f Total_psnr:%f',IT_Bits,ROI_psnr_IT,nonROI_psnr_IT,Total_psnr_IT)