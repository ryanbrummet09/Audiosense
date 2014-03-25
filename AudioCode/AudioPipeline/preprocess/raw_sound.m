function [ data ] = raw_sound( fileName )
%LoadRawSound Loads a '.audio' file
%   
f = fopen(fileName);
data = fread(f,inf,'short',0,'l');
fclose(f);
end