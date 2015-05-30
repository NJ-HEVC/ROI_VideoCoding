%Motion Compensation with ROI using Integeral Transform

close all;
clear;
clc;

load table;


%% Parameters
imageName = 'missa';
mbSize = 16;
p = 7;
QP_ROI = 25;   %20-44
QP_NON_ROI = 35;    %20-44
transBlockSize = 4; %For integer transform 4x4

%% Init
OrigianlNoofBits=0;
CompressedNoofBits=0;

% detector = vision.CascadeObjectDetector('FrontalFaceCART');   

filename = sprintf('IT_output_imageName_ROI%d_NON%d.avi',QP_ROI, QP_NON_ROI);
outputVideo = VideoWriter(fullfile('Output',filename));
outputVideo.FrameRate = 15;
open(outputVideo);



%% Read Image Frames  => total 30 frames
for i = 0:2:15
    
    imgINumber = i
    imgPNumber = i+1;
    
    if imgINumber < 10
        imgIFile = sprintf('Data/%s/gray/%s00%d.ras',imageName, imageName, imgINumber);
    elseif imgINumber < 100
        imgIFile = sprintf('Data/%s/gray/%s0%d.ras',imageName, imageName, imgINumber);
    end
    
    if imgPNumber < 10
        imgPFile = sprintf('Data/%s/gray/%s00%d.ras',imageName, imageName, imgPNumber);
    elseif imgPNumber < 100
        imgPFile = sprintf('Data/%s/gray/%s0%d.ras',imageName, imageName, imgPNumber);
    end
    
    imgI = double(imread(imgIFile));
    imgP = double(imread(imgPFile));
    imgI = imgI(:,1:352);
    imgP = imgP(:,1:352);
    
    [sizex,sizey] = size(imgI);
    
    OrigianlNoofBits(i+1) = (entropy(uint8(imgI))*sizex*sizey);
    OrigianlNoofBits(i+2) = (entropy(uint8(imgP))*sizex*sizey);
    
    % Detect the eye pair and get the boundary box
     bbox = [86,14,190,191];
%      bbox = step(detector, videoFrame);
    
    %% Integral Transform and Quantization + Inverse quantization and inverse transform
    [imgI_Reconstructed, entropy_I]  = roi_tranform_quantization(imgI, QP_ROI, QP_NON_ROI, bbox, transBlockSize);
    [imgP_Reconstructed, ~]  = roi_tranform_quantization(imgP, QP_ROI, QP_NON_ROI, bbox, transBlockSize);
    
    %%  Exhaustive Search for Motion Compensation
    [motionVect, computations] = motionEstES(imgP_Reconstructed,imgI_Reconstructed,mbSize,p);
    imgPComp = motionComp(imgI_Reconstructed, motionVect, mbSize);
%     psnr_pframes(i+1) = imgPSNR(imgP, imgPComp, 255);
%     psnr_iframes(i+1) = imgPSNR(imgI, imgI_Reconstructed, 255);

    [ROI_psnr_I(i+1), nonROI_psnr_I(i+1), Total_psnr_I(i+1)] = my_find_psnr(imgI, imgI_Reconstructed, bbox);
    [ROI_psnr_P(i+1), nonROI_psnr_P(i+1), Total_psnr_P(i+1)] = my_find_psnr(imgP, imgPComp, bbox);
    
    Residue_p = imgP - imgPComp;
    %Applying Same ROI compression for Residue - Prefer lossless !!!
    [ResidueP_Reconstructed, entropy_Residue]  = roi_tranform_quantization(Residue_p, QP_ROI, QP_ROI, bbox, transBlockSize);
    
    %% Bits calculation from entropy
    Compressed_NoOfbits(i+1) = (entropy_I) * sizex * sizey;
    Compressed_NoOfbits(i+2) = (entropy_Residue * sizex * sizey) + (entropy(motionVect) * size(motionVect,2) * 2) ;
    
    writeVideo(outputVideo,uint8(imgI_Reconstructed));
    writeVideo(outputVideo,uint8(imgPComp));
    
end

% release(detector);
close(outputVideo);

OriginalSize = (sum(OrigianlNoofBits))/1024;
CompressedSize = (sum(Compressed_NoOfbits))/1024;
comp_ratio = CompressedSize/OriginalSize;

Average_PSNR = mean([mean(Total_psnr_I),mean(Total_psnr_P)]);
ROI_PSNR = mean([mean(ROI_psnr_I),mean(ROI_psnr_P)]);
nonROI_PSNR = mean([mean(nonROI_psnr_I),mean(nonROI_psnr_P)]);

sprintf('Original size = %d kb, Compressed size= %d kb, Ratio = %f',OriginalSize,CompressedSize,comp_ratio)
sprintf('Compressed bitrate= %d kbps',CompressedSize/(1))  %total 30 frames & fps = 30
sprintf('ROI_psnr:%f  nonROI_psnr:%f Total_psnr:%f',ROI_PSNR, nonROI_PSNR, Average_PSNR)