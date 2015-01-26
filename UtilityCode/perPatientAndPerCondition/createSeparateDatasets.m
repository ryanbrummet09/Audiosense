function  [ids] = createSeparateDatasets( ipStruct, toSaveAt,frameSize,...
                                            patientOrCondition)
%CREATESEPARATEDATASETS Create files in the format that Ryan's patch knows
%   Input:
%           ipStruct        :       Structure containing the tables
%           toSaveAt        :       folder to save the individual tables at
%           frameSize       :       string containing the frame size
%           patientOrCondition :    true if patient, false if condition
% 
%   Output:
%           ids             :       patient or condition ids that are
%                                   present in in the struct

fn = fieldnames(ipStruct);
if 7 ~= exist(toSaveAt)
    mkdir(toSaveAt);
end
ids =  {};
for P=1:length(fn)
    id = strsplit(fn{P}, '_');
    id = id{end};
    ids{end+1} = id;
    if patientOrCondition
        filen = sprintf('surveyDataset_patient%s_%sms', id, frameSize);
    else
        filen = sprintf('surveyDataset_condition%s_%sms', id, frameSize);
    end
    toEval = sprintf('%s = ipStruct.(fn{P});', filen);
    eval(toEval);
    if patientOrCondition
        saveLocation = sprintf('%s/surveyDataset_patient%s_%sms.mat', ...
                    toSaveAt, id, frameSize);
    else
        saveLocation = sprintf('%s/surveyDataset_condition%s_%sms.mat', ...
                    toSaveAt, id, frameSize);
    end
    save(saveLocation, filen);
end

end

