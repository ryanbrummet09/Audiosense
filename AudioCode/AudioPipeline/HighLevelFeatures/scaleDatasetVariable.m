function [ surveyDataset ] = scaleDatasetVariable( surveyDataset, variableName )
%SCALEDATASETVARIABLE This function scales the dataset variable b/w 0 and 1
%   Input:
%       surveyDataset       :       Dataset containing the survey tokens
%       variableName        :       name of the variable we want to
%                                   normalize
% 
%   Output:
%       surveyDataset       :       The dataset with the input variable
%                                   normalized. This dataset is created
%                                   by eliminating NaNs from the variable
%                                   under question.
% 
% 
allVariables = surveyDataset.Properties.VarNames;
toFind = regexp(allVariables,variableName);
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
toEval = strcat('surveyDataset(~isnan(surveyDataset.',allVariables{foundAt},'),:)');
surveyDataset = evalin('caller',toEval);
uniquePatients = unique(surveyDataset.patient);
for P=1:length(uniquePatients)
    variableValue = dataset2cell(surveyDataset(surveyDataset.patient == uniquePatients(P),foundAt));
    variableValue = cell2mat(variableValue(2:end));
    maxVariable = max(variableValue);
    minVariable = min(variableValue);
    denom = maxVariable - minVariable;
    s = sprintf('Starting patient %d',uniquePatients(P));
    disp(s);
    for Q=1:length(surveyDataset)
        patient = dataset2cell(surveyDataset(Q,1));
        patient = cell2mat(patient(2:end));
        if patient == uniquePatients(P);
            varValue = dataset2cell(surveyDataset(Q,foundAt));
            varValue = cell2mat(varValue(2:end));
            surveyDataset(Q,foundAt) = dataset({(varValue - minVariable)/denom, allVariables{foundAt}});
        end
    end
    s = sprintf('Done patient %d',uniquePatients(P));
    disp(s);
end

end

