function [ROI_psnr, nonROI_psnr, Total_psnr] = my_find_psnr(originalImg, compressedImg, bbox)
originalImg = double(originalImg);
compressedImg = double(compressedImg);

[sizex, sizey] = size(originalImg);
Total_psnr = imgPSNR(originalImg, compressedImg, 255);


roi_orig = originalImg(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1);
roi_comp = compressedImg(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1);
ROI_psnr = imgPSNR(roi_orig,roi_comp,255);

non_roi_orig = originalImg;
non_roi_orig(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1) = 0;
non_roi_comp = compressedImg;
non_roi_comp(bbox(2):bbox(2)+bbox(4)-1, bbox(1):bbox(1)+bbox(3)-1) = 0;



[row col] = size(non_roi_orig);
[r_row r_col] = size(roi_orig);
err = 0;

for i = 1:row
    for j = 1:col
        err = err + (non_roi_orig(i,j) - non_roi_comp(i,j))^2;
    end
end
mse = err / (row*col - r_row*r_col);

nonROI_psnr = 10*log10(255*255/mse);


end