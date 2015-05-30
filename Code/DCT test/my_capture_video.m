close all;
clear all; 
clc;

%No of coefficients to keep
noOfCoeff_ROI = 64;
noOfCoeff_nonROI = 4;
%No of video frames to run for demo
noOfFramesToRun = 100;

%warning('off','all'); %.... diable warining msg ...;
vid = videoinput('winvideo',1, 'YUY2_320x240');
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb');
% vid.FrameRate =30;
vid.FrameGrabInterval = 1;  % distance between captured frames 
start(vid)

%finishup = onCleanup(@() myCleanupFun(vid)); %To fix webcam "winvideo not closed" issue during abnormal exit

vidRes = vid.VideoResolution; 
nBands = vid.NumberOfBands; 
hImage = image( zeros(vidRes(2), vidRes(1), nBands) ); 
% preview(vid, hImage); 

% Reference : http://www.mathworks.com/help/vision/ref/vision.cascadeobjectdetector-class.html
% Creat a Cascade object detector
detector = vision.CascadeObjectDetector('FrontalFaceCART');   
% Capture one frame to initialize things
videoFrame = getsnapshot(vid);
frameSize = size(videoFrame);

% Create the video player object
videoPlayer = vision.VideoPlayer('Position', [200 200 [frameSize(2), frameSize(1)]+30]);
videoPlayer2 = vision.VideoPlayer('Position', [200 200 [frameSize(2), frameSize(1)]+30]);

% Detect the face in every frame and overlay objects on top of it
% Initialize the live capture loop
runLoop = true;
frameCount = 0;
totalPSNR = 0;
% Start the live capture loop to run 100 frames or until stopped (window closed)
 while runLoop && frameCount < noOfFramesToRun
    % Take a snapshot each frame
    videoFrame = getsnapshot(vid);
    videoOut = videoFrame;
    % Detect the eye pair and get the boundary box
    bbox = step(detector, videoFrame);
   
    compOut = videoOut;
    if size(bbox, 1) == 1        
        % For the bbox 
        bbox = bbox + [-bbox(3)/4, -bbox(4)/2 ,bbox(3)/3 , 3*bbox(4)/4];
         %DCT Compression of video frame
    
    [compOut(:,:,1), ch1PSNR]  = dct_comp(videoOut(:,:,1),noOfCoeff_ROI, noOfCoeff_nonROI,bbox);
    [compOut(:,:,2), ch2PSNR]  = dct_comp(videoOut(:,:,2),noOfCoeff_ROI, noOfCoeff_nonROI,bbox);
    [compOut(:,:,3), ch3PSNR]  = dct_comp(videoOut(:,:,3),noOfCoeff_ROI, noOfCoeff_nonROI,bbox);
        
    totalPSNR = totalPSNR + ch1PSNR + ch2PSNR + ch3PSNR;
        
        IBody = insertObjectAnnotation(videoOut, 'rectangle',bbox,'ROI');
        videoOut = IBody;
    end
       
    % Display the video frame
     step(videoPlayer2, videoOut);
     step(videoPlayer, compOut);
     
     
     %Saving video frame - comment for realtime
%      imwrite(videoOut,'result/VideoOut_2.png');
%      imwrite(compOut,'result/compOut_2.png');
     
     
    % Update frame count
    frameCount = frameCount + 1;
    % Check whether the video player window has been closed.
%      runLoop = false;% isOpen(videoPlayer);
 end
% Release resources

% fprintf('Average PSNR = %f',totalPSNR/ (3 * frameCount) )

release(videoPlayer);
release(videoPlayer2);
release(detector);

stop(vid);
delete(vid);





