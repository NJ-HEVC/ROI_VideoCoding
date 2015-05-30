function [reconsImage, PSNR, entropy_dct]  = dct_comp(input_image, Scale_ROI, Scale_nonROI, bbox, QP_Scale)

intra_quant_mat = [8,16,19,22,26,27,29,34;16,16,22,24,27,29,34,37;19,22,26,27,29,34,34,38;22,22,26,27,29,34,37,40;22,26,27,29,32,35,40,48;26,27,29,32,35,40,48,58;26,27,29,34,38,46,56,69;27,29,35,38,46,56,69,83];
% QP_Scale = 4 ; %Step size
PSNR = 0; %Dont use this now
[h,w] = size(input_image);

x_no_blocks = w/8;
y_no_blocks = h/8;

s =  zeros(8,8);
sd = zeros(8,8);

x_roi_start = bbox(1)/8 -1;
x_roi_end = (bbox(1) + bbox(3))/8 + 1;
y_roi_start = bbox(2)/8 -1;
y_roi_end = (bbox(2) + bbox(4))/8 + 1;

roi_count = 0;
non_count = 0;
for i = 1:y_no_blocks
    for j=1:x_no_blocks
        yoffset = (i-1)*8;
        xoffset = (j-1)*8;
        s(1:8,1:8) = input_image( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
        sd (1:8,1:8) =  s(1:8,1:8); %level shifted
        dcts = dct2(sd);
        
        if( (x_roi_start <= j) && (j<=x_roi_end) && (y_roi_start <= i) && (i<=y_roi_end))
%              mod_dcts = round( (32*dcts + sign(dcts).*intra_quant_mat.*Scale_ROI)./(2 * Scale_ROI * intra_quant_mat)));
             mod_dcts = round( (32*Scale_ROI*dcts./(2 * QP_Scale * intra_quant_mat)));
            roi_count = roi_count + 1;
        else
            mod_dcts = round( (32*Scale_nonROI* dcts./(2 * QP_Scale* intra_quant_mat)));
            non_count = non_count + 1;
        end
        dcthat( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = mod_dcts(1:8,1:8);
    end
end

QuantizedImage = dcthat;
entropy_dct = entropy(uint8(QuantizedImage));

for i = 1:y_no_blocks
    for j=1:x_no_blocks
        yoffset = (i-1)*8;
        xoffset = (j-1)*8;
        recd_s(1:8,1:8) = QuantizedImage( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8);
        
           if( (x_roi_start <= j) && (j<=x_roi_end) && (y_roi_start <= i) && (i<=y_roi_end) )
               recd_sD =  2 * QP_Scale * recd_s.* intra_quant_mat./(32 * Scale_ROI ) ;
           else
               recd_sD =  2 * QP_Scale * recd_s.* intra_quant_mat./(32 * Scale_nonROI ) ;
           end

        reconsImage( yoffset+1 : yoffset+8 , xoffset+1 : xoffset+8) = idct2(recd_sD);
    end
end


end