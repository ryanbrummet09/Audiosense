function runDataThroughPatch(pathToCode, pids, frameSize, saveLocation, ...
                                fileLocations)
%RUNDATATHROUGHPATCH Function to run per patient data through patch
%   Input:
%           pathToCode      :       path to folder where patch code is
%                                   located
%           pids            :       pids obtained as an output from
%                                   createSeparateDatasets
%           frameSize       :       string containing frame size, same as
%                                   createSeparateDatasets
%           saveLocation    :       folder to save files at
%           fileLocation    :       Folder containing the files, the save
%                                   location of createSeparateDatasets
% 
%   SEE ALSO CREATESEPARATEDATASETS

addpath(pathToCode);

for P=1:length(pids)
    disp(sprintf('Working with patient %s', pids{P}));
    filen = sprintf('%s/surveyDataset_patient%s_%sms.mat', fileLocations, ...
                    pids{P}, frameSize);
    saveL = sprintf('%s/%sms/%s/', saveLocation, frameSize, pids{P});
    if 7 ~= exist(saveL)
        mkdir(saveL);
    end
    shabihPatchFunc(filen, saveL, 10, true);
end

end

