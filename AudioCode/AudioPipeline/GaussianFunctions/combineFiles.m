function [ combinedSet ] = combineFiles( fileList )
%COMBINEFILES combine the file features into matrices
%   The file list is a cell array that contains the file paths to the
%   feature files, these are loaded and combined into a single matrix
%   combinedSet
combinedSet = [];
for P=1:length(fileList)
        [pid,cid,sid] = getMATFileInfo(fileList{P});
        fileFeatures = load(fileList{P});
        fileFeatures = fileFeatures.var;
        [r,c] = size(fileFeatures);
        temp = zeros(r,c+3);
        temp(:,1) = pid;
        temp(:,2) = cid;
        temp(:,3) = sid;
        temp(:,4:end) = fileFeatures;
        if 1 == P
            combinedSet = temp;
        else
            combinedSet = [combinedSet; temp];
        end
end

end

