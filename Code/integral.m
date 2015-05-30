
clear all;
clc;

load table;
% global Table_coeff0 Table_coeff1 Table_coeff2 Table_coeff3
% global Table_run Table_zeros


X = [5 11 8 10
     9 8 4 12
     1 10 13 4
     19 6 15 7]


% X= (randi(255,4,4))

 
EX = entropy(uint8(X))

 QP = 10;  % 0-51
 
 W = integer_transform(X);
 
 Z = quantization(W,QP)
 
 E = entropy(Z)
 Wi = inv_quantization(Z,QP);

 Y = inv_integer_transform(Wi);

 %  post scaling - very important 
 Xi = round(Y/64);
 


 
 
 
 