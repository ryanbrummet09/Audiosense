function extractFiniteData(fileList,secondsToExtract,...
                            pathToSave, Fs, extractDatenum)
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
%           extractDatenum      :           Flag indicating if serial
%                                           datenum should be extracted
%                                           instead of actual date and time
%                                           values

toExtract = secondsToExtract*Fs;
if 7 ~= exist(pathToSave)
    mkdir(pathToSave);
end

if 4 == nargin
    extractDatenum = false;
end

for P=1:length(fileList)
    data = getSoundData(fileList{P});
    if toExtract <= length(data)
        data = data(1:toExtract);
    end
    [p,c,s,d] = getInfo(fileList{P}, extractDatenum);
    if extractDatenum
        toWriteTo = sprintf('%s/%d_%d_%d_%f.audio',pathToSave,p,c,s,d);
    else
        toWriteTo = sprintf('%s/%d_%d_%d_%s.audio',pathToSave,p,c,s,d);
    end
    f = fopen(toWriteTo,'w');
    fwrite(f,data,'short',0,'l');
    fclose(f);
    disp(sprintf('Written %s',toWriteTo));
end

end

