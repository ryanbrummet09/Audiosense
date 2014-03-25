function [ HighEnergyFrame, LowEnergyIndicator ] = frameProcessing( cleanFrame, tau )
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
%   HighEnergyFrame     :       This is the same as the input frame if the
%                               low energy indicator bit is false
%   LowEnergyIndicator  :       This indicates whether the frame failed or
%                               passed the RMS filter. If it is true, then
%                               the HighEnergyFrame would contain the 
%                               length of the low-energy frame, else
%                               the HighEnergyFrame would be the same as
%                               the input frame

%cleanFrame = buzzBeepFilter(frame);

if rmsFilter(cleanFrame,tau)
    LowEnergyIndicator = true;
    HighEnergyFrame = [length(cleanFrame)];
else
    LowEnergyIndicator = false;
    HighEnergyFrame = cleanFrame;
end

end

