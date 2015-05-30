function [ReconstructedFrame] = my_tranform_quantization(OriginalFrame, QP, transBlockSize)

[frame_size_X,frame_size_Y] = size(OriginalFrame);

QuantizedFrame = zeros(frame_size_X,frame_size_Y);
ReconstructedFrame = zeros(frame_size_X,frame_size_Y);


for i=0:(frame_size_X/transBlockSize)-1
    for j=0:(frame_size_Y/transBlockSize)-1
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

Origianal_Image_Entropy = entropy(uint8(OriginalFrame));
Quantized_Image_Entropy = entropy(uint8(QuantizedFrame));

TotalNumberOfBits_Original = Origianal_Image_Entropy * frame_size_X * frame_size_Y;
TotalNumberOfBits_Quantized = Quantized_Image_Entropy * frame_size_X * frame_size_Y;

kbps(QP+1) = 30 * TotalNumberOfBits_Quantized/1024;
PSNR(QP+1) = psnr(ReconstructedFrame,OriginalFrame);

end