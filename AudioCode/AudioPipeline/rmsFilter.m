function [ LEIndicator ] = rmsFilter( frame, tau )
%RMSFILTER This filters out low energy frames
%   RMSFILTER looks at the input signal and determines whether it possesses
%   sufficient energy (\tau). 
%   It takes two inputs:
%   frame       :           the input value (should have dimensions 1 x N)
%   tau         :           threshold value
%
%
%   The filter gives as output a bit (LEIndicator) indicating if the input
%   is low-energy or not

if rms(frame) <= tau
    LEIndicator = true;
else
    LEIndicator = false;
end

end

