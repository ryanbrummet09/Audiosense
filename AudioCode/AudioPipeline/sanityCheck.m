function [ fname, removedFiles ] = sanityCheck( fname )
%SANITYCHECK Removes the zero sized files from consideration list
%   Checks if the size of the files to be considered is equal to 0 bytes,
%   if so, then it removes them from the consideration list.
%   
%   Input:
%           fname       :       list of files to be considered
% 
%   Output:
%           fname       :       file list with the zero-sized files removed
%           removedFiles:       list of removed files

toKeep = true(size(fname));
removedFiles = {};
for P =1:length(fname)
    fileStruct = dir(fname{P});
    if 0 == fileStruct.bytes
        toKeep(P) = false;
        removedFiles{end+1} = fname{P};
    end
end

fname = fname(toKeep);

end

