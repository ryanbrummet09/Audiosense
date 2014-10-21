function [ combinedSet ] = combineFiles( fileList, labelOrder )
%COMBINEFILES combine the file features into matrices
%   The file list is a cell array that contains the file paths to the
%   feature files, these are loaded and combined into a single matrix
%   combinedSet.
%   The optional parameter, labelOrder, is used to indicate that there is a
%   possibility of more than one label being associated with a file. This
%   essentially populates the 4th column to the combinedSet output to
%   indicates the position of the label in the cell array labelOrder.
%   Eg. labelOrder = {'speech','media_speech','media_music','music'}
combinedSet = [];
multLabels = false;
if 2 == nargin
    multLabels = true;
end
for P=1:length(fileList)
        disp(sprintf('Working with %d, %s',P,fileList{P}));
        [pid,cid,sid,label] = getMATFileInfo(fileList{P},multLabels);
        idx = -1;
        if multLabels
            idx = find(strcmpi(label,labelOrder));
        end
        fileFeatures = load(fileList{P});
        fileFeatures = fileFeatures.var;
        if isempty(fileFeatures)
            disp('Empty!');
            continue;
        end
        [r,c] = size(fileFeatures);
        temp = zeros(r,c+4);
        temp(:,1) = pid;
        temp(:,2) = cid;
        temp(:,3) = sid;
        temp(:,4) = idx;
        temp(:,5:end) = fileFeatures;
        if 1 == P
            combinedSet = temp;
        else
            combinedSet = [combinedSet; temp];
        end
end

end

