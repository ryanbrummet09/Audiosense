function runDataThroughPatch(pathToCode, ids, frameSize, saveLocation, ...
                                fileLocations, patientOrCondition)
%RUNDATATHROUGHPATCH Function to run per patient data through patch
%   Input:
%           pathToCode      :       path to folder where patch code is
%                                   located
%           ids             :       ids obtained as an output from
%                                   createSeparateDatasets
%           frameSize       :       string containing frame size, same as
%                                   createSeparateDatasets
%           saveLocation    :       folder to save files at
%           fileLocation    :       Folder containing the files, the save
%                                   location of createSeparateDatasets
%           patientOrCondition  :   true if patient, false for condition
% 
%   SEE ALSO CREATESEPARATEDATASETS

addpath(pathToCode);

for P=1:length(ids)
    if patientOrCondition
        temp = 'patient';
    else
        temp = 'condition';
    end
    disp(sprintf('Working with %s %s', temp, ids{P}));
    filen = sprintf('%s/surveyDataset_%s%s_%sms.mat', fileLocations, ...
                    temp, ids{P}, frameSize);
    saveL = sprintf('%s/%sms/%s/', saveLocation, frameSize, ids{P});
    if 7 ~= exist(saveL)
        mkdir(saveL);
    end
    shabihPatchFunc(filen, saveL, 10, true);
end

end

