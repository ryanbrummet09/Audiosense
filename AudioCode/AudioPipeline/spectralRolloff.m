function [ srf ] = spectralRolloff( fftAbsScaled,freqRange,ulimit )
%SPECTRALROLLOFF calculates the spectral rolloff of the signal
%   This calculates the frequency below which a certain amount of the
%   signal resides (93% by default). The input is the output of GETFFT and
%   ulimit, the percentage to calculate. The output is the frequency.
%
%   See also, GETFFT
if nargin == 2
    ulimit = 0.93;
end
x = sum(fftAbsScaled);
y = x;
v = 0;
for P=length(fftAbsScaled):-1:1
    y = y-fftAbsScaled(P);
    if y/x < ulimit
        y=y+fftAbsScaled(P);
        if y/x >=ulimit
            if length(fftAbsScaled) < P+1
                v = P; % need these checks in case the value lies at the last element
            else
                v = P+1;
            end
%             v = P+1
            break;
        end
    end    
end
if 0 == v
    v = 1;
end
srf = freqRange(v);
end

