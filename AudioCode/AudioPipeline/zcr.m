function [ zeroCrossRate ] = zcr( signal )
%ZCR Summary of this function goes here
%   Detailed explanation goes here
zeroCrossRate = sum(abs(diff(signal>0)))/length(signal);

end

