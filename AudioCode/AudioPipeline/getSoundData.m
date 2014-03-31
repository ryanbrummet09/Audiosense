function [ data ] = getSoundData( fileName )
%GETSOUNDDATA Extracts the sound samples
%   This takes as input the file name and outputs the samples of audio
%   signal present in it. There are a few assumptions made in this
%   function, first, the file is a raw binary file; second, the samples are
%   stored as shorts. Third, the data is in the little endian format.
f = fopen(fileName);
data = fread(f,inf,'short',0,'l');
fclose(f);
end
