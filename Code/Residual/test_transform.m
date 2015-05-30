
clear all;
clc;

load table;
global Table_coeff0 Table_coeff1 Table_coeff2 Table_coeff3
global Table_run Table_zeros


% X = [5 11 8 10
%      9 8 4 12
%      1 10 11 4
%      19 6 15 7];
 

 X = magic(4) 
 

 for itr = 1:52
 QP = itr-1;
 
 W = integer_transform(X);
 
 Z = quantization(W,QP);
 
 [bits] = enc_cavlc(Z, 0, 0);
 length(bits)
 [Z1,i] = dec_cavlc(bits,0,0);
 
 diff = Z - Z1;
 
 Wi = inv_quantization(Z,QP);

 Y = inv_integer_transform(Wi);

 %  post scaling - very important 
 Xi = round(Y/64)
 
 XR = reshape(X,16,1);
 XiR = reshape(Xi,16,1);
RMS(itr) = rms(XiR-XR);

 end
 plot(RMS);
 
 
 
 