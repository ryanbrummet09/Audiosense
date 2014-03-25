function [ specAmp,freq ] = getFFT( signal,Fs )
%GETFFT Summary of this function goes here
%   Detailed explanation goes here

freq = -Fs/2:Fs/(length(signal)-1):Fs/2;
specAmp = abs(fftshift(fft(signal)));

end

