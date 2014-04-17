function [ GMMHistWithTarget ] = addTargetVariable( GMMHistWithoutTarget, surveyDataset, variableName)
%ADDTARGETVARIABLE adds the target variable to the input historgram
%   This adds the target variable (for the machine learning algorithm) to
%   the GMM matrix. 
%   Input:
%           GMMHistWithoutTarget        :       GMM matrix
%           surveyDataset               :       Dataset containing the
%                                               various entries from the 
%                                               surveys
%           variableName                :       title of the target
%                                               variable in the survey
%   Output:
%           GMMHistWithTarget           :       GMM Matrix with target
%                                               variable at the end

toFind = regexp(surveyDataset.Properties.VarNames,variableName);
foundAt = [];
for P=1:length(toFind)
    if toFind{P} == [1]
       foundAt(end+1) = P; 
    end
end
if length(foundAt) > 1
    opts = '';
    for K =1:length(foundAt)
        sn = sprintf('%d : %s',K,surveyDataset.Properties.VarNames{foundAt(K)});
        opts = strcat(opts,sn,'\n');
    end
    s = sprintf('I found more than one variable that matches your description, please make a selection: %s \nChoice:',opts);
    foundAt = foundAt(str2num(input(s,'s')));
end
[r c] = size(GMMHistWithoutTarget);
GMMHistWithTarget = GMMHistWithoutTarget;
GMMHistWithTarget(:,end+1) = 0;
for P =1:r
    dV = dataset2cell(surveyDataset(surveyDataset.patient==GMMHistWithTarget(P,1) & ...
        surveyDataset.condition == GMMHistWithTarget(P,2) & ...
        surveyDataset.session == GMMHistWithTarget(P,3),foundAt));
    if length(dV) < 2
        dV{end+1} = NaN;
    end
    GMMHistWithTarget(P,end) = dV{end};
end

end

