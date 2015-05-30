function [ReconstructedFrame, entropy_IT] = roi_tranform_quantization(OriginalFrame, QP_ROI, QP_NON_ROI,bbox, transBlockSize)

[frame_size_X,frame_size_Y] = size(OriginalFrame);

QuantizedFrame = zeros(frame_size_X,frame_size_Y);
ReconstructedFrame = zeros(frame_size_X,frame_size_Y);

x_roi_start = bbox(1)/transBlockSize -1;
x_roi_end = (bbox(1) + bbox(3))/transBlockSize + 1;
y_roi_start = bbox(2)/transBlockSize -1;
y_roi_end = (bbox(2) + bbox(4))/transBlockSize + 1;

for i=0:(frame_size_X/transBlockSize)-1
    for j=0:(frame_size_Y/transBlockSize)-1
        
        if( (x_roi_start <= (j+1)) && ((j+1)<=x_roi_end) && (y_roi_start <= (i+1)) && ((i+1)<=y_roi_end))
            QP = QP_ROI;
        else
            QP = QP_NON_ROI;
        end
        
        X = OriginalFrame(i*4+1:4+i*4 , j*4+1:4+j*4);
        
        W = integer_transform(X);
        Z = quantization(W,QP);
        QuantizedFrame(i*4+1:4+i*4 , j*4+1:4+j*4) = Z;
        
        Wi = inv_quantization(Z,QP);
        Y = inv_integer_transform(Wi);
        
        %Post scaling
        Xi = round(Y/64);
        ReconstructedFrame(i*4+1:4+i*4 , j*4+1:4+j*4) = Xi;
    end
end
entropy_IT = entropy(uint8(QuantizedFrame));
end