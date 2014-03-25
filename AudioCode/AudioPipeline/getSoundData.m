function [ data ] = getSoundData( fileName )
%GETSOUNDDATA Summary of this function goes here
%   Detailed explanation goes here
f = fopen(fileName);
data = fread(f,inf,'short',0,'l');
fclose(f);
end
