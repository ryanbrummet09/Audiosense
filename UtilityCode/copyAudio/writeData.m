function writeData( data, fileName)
%WRITEDATA write the audio file data to a file
%   Input: 
%           data        :       audio file data
%           fileName    :       name of file and full path
% 

f = fopen(fileName, 'wb');
fwrite(f, data, 'short', 0, 'l');
fclose(f);

end

