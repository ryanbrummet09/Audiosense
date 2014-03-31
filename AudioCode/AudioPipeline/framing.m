function [ buzzMask, beepMask, frames ] = framing( audioSignal, frequency, frameSizeSeconds, locs_buzz, locs_beep )
%FRAMING frames the given file in frames of size given as input
%   FRAMING is the first component of the audio pipeline. It takes as input
%   five things:
%   audioSignal         :       the audio signal
%   frequency           :       frequency of the signal
%   frameSizeSeconds    :       the size of the frame required
%   locs_buzz           :       location of the buzzes
%   locs_beep           :       locaiton of the beeps
%
%
%   It spits out an array [buzzMask, beepMask, frames]
%   buzzMask is the bit mask indicating out of all frames where do the
%   buzzes occur
%   beepMask is the bit mask indicating out of all frames where do the
%   beeps occur
%   frames is a matrix of size M x N where,
%   M = # of frames (total samples/(frameSizeSeconds * frequency))
%   N = frame size (frameSizeSeconds * frequency)
%   
%   The following assumptions are made about the file:
%   1. The file is in the raw binary form.
%   2. Each sample is stored in the file as a short.
%   3. Data is stored in the little endian form.

%audioSignal = getSoundData(filename);
frameSizeSamples = frequency .* frameSizeSeconds;
frames = enframe(audioSignal,frameSizeSamples,frameSizeSamples,'r');
buzzMask = false(1,length(frames));
beepMask = false(1,length(frames));

for P=1:length(locs_buzz)
    frameNo = ceil(locs_buzz(P)./frameSizeSamples);
    if false == buzzMask(frameNo)
        buzzMask(frameNo) = true;
    end
end

for P=1:length(locs_beep)
    frameNo = ceil(locs_beep(P)./frameSizeSamples);
    if false == beepMask(frameNo)
        beepMask(frameNo) = true;
    end
end
end