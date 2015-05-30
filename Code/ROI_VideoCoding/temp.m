% roi = 64;
% non_roi = 16;
%
%
% [reconsImage, PSNR1]  = dct_comp(videoFrame(:,:,1), roi, non_roi, bbox);
% [reconsImage, PSNR2]  = dct_comp(videoFrame(:,:,2), roi, non_roi, bbox);
% [reconsImage, PSNR3]  = dct_comp(videoFrame(:,:,3), roi, non_roi, bbox);
%
% avgPSNR = (PSNR1 + PSNR2+ PSNR3 )/3



%Getting psnr vs coeff

x = [2,4,8,16,32,64];
psnr64 = [34.9,37.6,41.5,45.9,52.7,315.9];
psnr32 = [34.3,37.3,40.5,44.1,47.7];
psnr16 = [33.91, 36.34,38.72,40.72];

hold on
plot(x(1:5),psnr64(1:5),'ko-');
plot(x(1:5),psnr32,'bo-');
plot(x(1:4),psnr16,'ro-');
title('PSNR vs No of non ROI DCT coefficients');
xlabel('No of non ROI DCT Coefficients');
ylabel('Average PSNR of full video frame');
legend('ROI Coeffs = 64','ROI Coeffs = 32','ROI Coeffs = 16');
hold off