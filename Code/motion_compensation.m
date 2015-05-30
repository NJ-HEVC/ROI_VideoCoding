%Motion Compensation

close all;
clear;
clc;

load table;

% % OriginalFrame = double(rgb2gray(imread('me.png')));
% VideoFrames = VideoReader('Data/akiyo_qcif.yuv');
% % VideoFrames =  VideoReader('Data/Wildlife.wmv');

%% Parameters
imageName = 'missa';
mbSize = 16;
p = 7;
QP = 25;
transBlockSize = 4; %For integer transform 4x4


%% Init
OrigianlNoofBits=0;
CompressedNoofBits=0;

filename = sprintf('output_video_Q%d.avi',QP);
% outputVideo = VideoWriter(fullfile('Output','output_video_.avi'));
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
    
    
    %% Integral Transform and Quantization + Inverse quantization and inverse transform
    imgI_Reconstructed = my_tranform_quantization(imgI, QP, transBlockSize);
    imgP_Reconstructed = my_tranform_quantization(imgP, QP, transBlockSize);
    
    
    
    
    %%  Exhaustive Search for Motion Compensation
    [motionVect, computations] = motionEstES(imgP_Reconstructed,imgI_Reconstructed,mbSize,p);
    imgPComp = motionComp(imgI, motionVect, mbSize);
    psnr_pframes(i+1) = imgPSNR(imgP, imgPComp, 255);
    psnr_iframes(i+1) = imgPSNR(imgI, imgI_Reconstructed, 255);
%     EScomputations(i+1) = computations;
    
    
    %% I frame
    Compressed_NoOfbits(i+1) = (entropy(imgI_Reconstructed) * sizex * sizey);
    %%  Compression of P frames
    Residue_p = imgP - imgP_Reconstructed;
    Compressed_NoOfbits(i+2) = (entropy(Residue_p) * sizex * sizey) + (entropy(motionVect) * size(motionVect,2) * 2) ;
    
    writeVideo(outputVideo,uint8(imgI_Reconstructed));
    writeVideo(outputVideo,uint8(imgPComp));
    
end

close(outputVideo);


% hold on
% plotyy(1:52,PSNR,1:52,kbps);
% legend('PSNR','kbps');
% hold off
OriginalSize = (sum(OrigianlNoofBits))/1024
CompressedSize = (sum(Compressed_NoOfbits))/1024

Average_PSNR = mean([mean(psnr_iframes),mean(psnr_pframes)])


