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
    mainFilename = strsplit(fileToConsider, '/');
    try
        data = readData(fileToConsider, 16000, 90);
    catch errReading
        errReading
        disp(sprintf('There was an error reading the file %s, skipping',...
            mainFilename{end}));
        continue;
    end
    disp(sprintf('Working with %s', mainFilename{end}));
    toWriteAt = strcat(finalFolder, '/', mainFilename{end});
    try
        writeData(data, toWriteAt);
    catch errWriting
        errWriting
        disp(sprintf('There was an error writing the file %s, skipping',...
            mainFilename{end}));
        continue;
    end
    finalFileList{P} = toWriteAt;
end
delete(parObj);

end

