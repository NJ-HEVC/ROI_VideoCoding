%Motion Compensation with ROI using DCT

close all;
clear;
clc;


%% Motion Compensation Parameters
imageName = 'missa';
mbSize = 4;
p = 7;

%DCT Params - Scaling factor
Scale_ROI = 0.85;   %0-1  1 is good
Scale_nonROI = 0.009;    %0-1  | 0.03 is somewhat blocky | 0.01 is very blocky |
QP_Scale = 4 % Step Size

%% Init
OrigianlNoofBits=0;
CompressedNoofBits=0;

% detector = vision.CascadeObjectDetector('FrontalFaceCART');  

filename = sprintf('DCT_output_imageName_ROI%f_NON%f.avi',Scale_ROI, Scale_nonROI);
outputVideo = VideoWriter(fullfile('Output',filename));
outputVideo.FrameRate = 15;
open(outputVideo);



%% Read Image Frames
for i = 0:2:30
    
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
    
    %% DCT and Quantization + Inverse quantization and inverse transform
   
    [imgI_Reconstructed, ~ , entropy_I]  = dct_comp(imgI,Scale_ROI, Scale_nonROI, bbox, QP_Scale);
    [imgP_Reconstructed, ~]  = dct_comp(imgP,Scale_ROI, Scale_nonROI, bbox, QP_Scale);
    
    %%  Exhaustive Search for Motion Compensation
    [motionVect, computations] = motionEstES(imgP_Reconstructed,imgI_Reconstructed,mbSize,p);
    imgPComp = motionComp(imgI_Reconstructed, motionVect, mbSize);
%     psnr_pframes(i+1) = imgPSNR(imgP, imgPComp, 255);
%     psnr_iframes(i+1) = imgPSNR(imgI, imgI_Reconstructed, 255);

     [ROI_psnr_I(i+1), nonROI_psnr_I(i+1), Total_psnr_I(i+1)] = my_find_psnr(imgI, imgI_Reconstructed, bbox);
    [ROI_psnr_P(i+1), nonROI_psnr_P(i+1), Total_psnr_P(i+1)] = my_find_psnr(imgP, imgPComp, bbox);
    
    Residue_p = imgP - imgPComp;
    %Applying Same ROI compression for Residue - Prefer lossless !!!
    [ResidueP_Reconstructed, ~, entropy_Residue]  = dct_comp(Residue_p, Scale_ROI, Scale_ROI, bbox, QP_Scale);
    
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