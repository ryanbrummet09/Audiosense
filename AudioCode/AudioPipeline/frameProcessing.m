function [ LowEnergyIndicator ] = frameProcessing( cleanFrame, tau )
%FRAMEPROCESSING The frame admission control component
%   FRAMEPROCESSING determines whether the frame given as input should be
%   admitted for further processing. It uses the buzz and beep removal
%   filters and then passes the frame through the RMS filter. It takes as
%   input two arguments:
%   frame       :       the signal frame
%   tau         :       the threshold for the RMS filter
%
%
%   There are two outputs:
%   LowEnergyIndicator  :       This indicates whether the frame failed or
%                               passed the RMS filter.

%cleanFrame = buzzBeepFilter(frame);

if rmsFilter(cleanFrame,tau)
    LowEnergyIndicator = true;
else
    LowEnergyIndicator = false;
end

end

