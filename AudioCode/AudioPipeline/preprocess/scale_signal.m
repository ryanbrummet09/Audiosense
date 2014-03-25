function [ x_scaled ] = ScaleSignal( x, a, b )
%ScaleSignal Scales the signal in [a, b] range
%   
x_scaled = (x-min(x))*(b-a)/(max(x)-min(x)) + a;
end


