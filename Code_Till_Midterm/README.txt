A live demo based on video streamed from webcam can be done by running the standalone file : my_capture_video.m

To change the number of frames for which the demo runs - modify noOfFramesToRun = 100; to some other value.

To modify the number of DCT coefficients to be used for ROI and non ROI : 
noOfCoeff_ROI = 64;
noOfCoeff_nonROI = 4;

modify the above variables to any value between (1-64)



DCT Compression :

[reconsImage, PSNR]  = dct_comp(input_image, noOfcoeff_ROI, noOfcoeff_nonROI, bbox)