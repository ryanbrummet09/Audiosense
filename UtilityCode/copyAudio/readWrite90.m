function [ finalFileList ] = readWrite90( fileList, finalFolder )
%READWRITE90 read the audio files, select 90s and write that
%   Input:
%           fileList        :       list of audio files to read
%           finalFolder     :       path to folder where 90s files will be
%                                   stored
% 
%   Output:
%           finalFileList   :       list of file paths where files have
%                                   been written

finalFileList = cell(size(fileList));
parObj = parpool;
parfor P=1:length(fileList)
    fileToConsider = fileList{P};
    data = readData(fileToConsider, 16000, 90);
    mainFilename = strsplit(fileToConsider, '/');
    toWriteAt = strcat(finalFolder, '/', mainFilename{end});
    writeData(data, toWriteAt);
    finalFileList{P} = toWriteAt;
end
delete(parObj);

end

