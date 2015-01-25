function  [pids] = createSeparateDatasets( ipStruct, toSaveAt, frameSize )
%CREATESEPARATEDATASETS Create files in the format that Ryan's patch knows
%   Input:
%           ipStruct        :       Structure containing the tables
%           toSaveAt        :       folder to save the individual tables at
%           frameSize       :       string containing the frame size
% 
%   Output:
%           pids            :       patient ids for patients which have
%                                   are present

fn = fieldnames(ipStruct);
if 7 ~= exist(toSaveAt)
    mkdir(toSaveAt);
end
pids =  {};
for P=1:length(fn)
    pid = strsplit(fn{P}, '_');
    pid = pid{end};
    pids{end+1} = pid;
    filen = sprintf('surveyDataset_patient%s_%sms', pid, frameSize);
    toEval = sprintf('%s = ipStruct.(fn{P});', filen);
    eval(toEval);
    saveLocation = sprintf('%s/surveyDataset_patient%s_%sms.mat', ...
                    toSaveAt, pid, frameSize);
    save(saveLocation, filen);
end

end

