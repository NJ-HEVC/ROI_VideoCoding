%Motion Compensation

close all;
clear;
clc;

load table;

OriginalFrame = double(rgb2gray(imread('me.png')));

[frame_size_X,frame_size_Y] = size(OriginalFrame);

QuantizedFrame = zeros(frame_size_X,frame_size_Y);
ReconstructedFrame = zeros(frame_size_X,frame_size_Y);


% Quantization Parameter
QP = 20;  % 0-51

%Transform Block size
transBlockSize = 4;

for i=1:(frame_size_X/transBlockSize)-1
    for j=1:(frame_size_Y/transBlockSize)-1
        X = OriginalFrame(i*4:3+i*4 , j*4:3+j*4);
       
        W = integer_transform(X);
        Z = quantization(W,QP);
        QuantizedFrame(i*4:3+i*4 , j*4:3+j*4) = Z;

        Wi = inv_quantization(Z,QP);
        Y = inv_integer_transform(Wi);
        
        %Post scaling
        Xi = round(Y/64); 
        ReconstructedFrame(i*4:3+i*4 , j*4:3+j*4) = Xi;
    end
end

image(OriginalFrame);
figure;
image(ReconstructedFrame);

Origianal_Image_Entropy = entropy(uint8(OriginalFrame))
Quantized_Image_Entropy = entropy(uint8(QuantizedFrame))

TotalNumberOfBits_Original = Origianal_Image_Entropy * frame_size_X * frame_size_Y
TotalNumberOfBits_Quantized = Quantized_Image_Entropy * frame_size_X * frame_size_Y