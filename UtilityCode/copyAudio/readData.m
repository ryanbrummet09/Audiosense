function [ data ] = readData( fileName, fs, secondsToRead)
%READDATA Read the audio file for specified duration
%   Input:
%           fileName        :       full file name and path
%           fs              :       sampling frequency (default 16000)
%           secondsToRead   :       number of seconds to read the data
%                                   (default is full file)
% 
%   Output:
%           data            :       the extracted data


if 1 == nargin
    fs = 16000;
    secondsToRead = Inf;
elseif 2 == nargin
    secondsToRead = Inf;
end

secondsToRead = fs * secondsToRead;

f = fopen(fileName, 'r');
data = fread(f, secondsToRead, 'short', 0, 'l');
fclose(f);
end

