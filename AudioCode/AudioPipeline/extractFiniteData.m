function extractFiniteData(fileList,secondsToExtract,...
                            pathToSave, Fs)
%EXTRACTFINITEDATA extract a finite amount of data from audio file
%   Input:
%           fileList            :           list of audio files to work
%                                           with
%           secondsToExtract    :           seconds to extract from the
%                                           full data, if this value is
%                                           greater than the actual length
%                                           of the data, the whole file
%                                           would be used
%           pathToSave          :           folder to save the files in
%           Fs                  :           sampling frequency of audio
toExtract = secondsToExtract*Fs;
if 7 ~= exist(pathToSave)
    mkdir(pathToSave);
end
for P=1:length(fileList)
    data = getSoundData(fileList{P});
    if toExtract <= length(data)
        data = data(1:toExtract);
    end
    [p,c,s] = getInfo(fileList{P});
    toWriteTo = sprintf('%s/%d_%d_%d.audio',pathToSave,p,c,s);
    f = open(toWriteTo,'w');
    fwrite(f,data,'short',0,'l');
    fclose(f);
end

end

