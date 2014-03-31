function [ zeroCrossRate ] = zcr( signal )
%ZCR calculates the zero crossing rate of the input signal
%   [zero crossing rate ] = zrc( input signal)
%   the input signal can be obtained from getSoundData
%   
%   See also, GETSOUNDDATA
zeroCrossRate = sum(abs(diff(signal>0)))/length(signal);

end

