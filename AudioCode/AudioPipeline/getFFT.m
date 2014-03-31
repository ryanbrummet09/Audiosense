function [ specAmp,freq ] = getFFT( signal,Fs )
%GETFFT calculates the FFT of the input
%   This function outputs the real part of the FFT. It takes as input two
%   things, the signal and the sampling frequency. The output is an array
%   containing two parts,
%   specAmp         :       the contribution of each frequency
%   freq            :       the value of frequency at each point

freq = -Fs/2:Fs/(length(signal)-1):Fs/2;
specAmp = abs(fftshift(fft(signal)));

end

