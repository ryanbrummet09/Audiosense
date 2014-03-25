function [ frames ] = framing( audioSignal, frequency, frameSizeSeconds )
%FRAMING frames the given file in frames of size given as input
%   FRAMING is the first component of the audio pipeline. It takes as input
%   three things:
%   filename            :       the name of the signal containing file
%   frequency           :       frequency of the signal
%   frameSizeSeconds    :       the size of the frame required
%
%
%   It spits out a matrix, frames, of size M x N where,
%   M = # of frames (total samples/(frameSizeSeconds * frequency))
%   N = frame size (frameSizeSeconds * frequency)
%
%
%   The following assumptions are made about the file:
%   1. The file is in the raw binary form.
%   2. Each sample is stored in the file as a short.
%   3. Data is stored in the little endian form.

%audioSignal = getSoundData(filename);
frameSizeSamples = frequency .* frameSizeSeconds;
frames = enframe(audioSignal,frameSizeSamples,frameSizeSamples,'r');

end

