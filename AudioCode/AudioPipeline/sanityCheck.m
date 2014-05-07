function [ fname, removedFiles, numberOfRows ] = sanityCheck( fname, ...
                                                 frequency, frameSize, singleFile )
%SANITYCHECK Removes the zero sized files from consideration list
%   Checks if the size of the files to be considered is equal to 0 bytes,
%   if so, then it removes them from the consideration list.
%   
%   Input:
%           fname       :       list of files to be considered
%           frequency   :       sampling frequency
%           frameSize   :       frame size in seconds
%           singleFile  :       optional flag to indicate if there is just
%                               one file
% 
%   Output:
%           fname       :       file list with the zero-sized files removed
%           removedFiles:       list of removed files
%           numberOfRows:       number of rows for initializing the
%                               featureVector

if nargin == 3
    singleFile = false;
end


frameSizeInSamples = frequency * frameSize;
numberOfRows = 0;
removedFiles = {};

if ~singleFile
    toKeep = true(size(fname));
    for P =1:length(fname)
        fileStruct = dir(fname{P});
        numberOfRows = numberOfRows + fileStruct.bytes;
        if 0 == fileStruct.bytes
            toKeep(P) = false;
            removedFiles{end+1} = fname{P};
        end
    end
    fname = fname(toKeep);
    numberOfRows = numberOfRows/2;
    numberOfRows = ceil(numberOfRows/frameSizeInSamples);
else
    fileStruct = dir(fname);
    numberOfRows = numberOfRows + fileStruct.bytes;
    if 0 == fileStruct.bytes
        removedFiles = fname;
        fname = '';
    else
        numberOfRows = numberOfRows/2;
        numberOfRows = ceil(numberOfRows/frameSizeInSamples);
    end
end
end

