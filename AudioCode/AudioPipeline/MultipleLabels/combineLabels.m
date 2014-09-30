function [ multipleLabels ] = combineLabels( multipleLabels, surveyData)
%COMBINELABELS get user defined labels for manually annotated audio
%   Input:
%           multipleLables      :       table containing the multiple
%                                       labels for files
%           surveyData          :       table containing the survey data
% 
%   Output:
%           multipleLabels      :       table containing the multiple
%                                       labels for files along with user
%                                       defined labels

n = height(multipleLabels);
labels = cell(n,1);
acLables = {'speech','speech','speech','media','speech','nonspeech'};
for P=1:n
    temp = multipleLabels(P,:);
    ac = surveyData.ac(surveyData.patient == temp.patient & ...
        surveyData.condition == temp.condition & ...
        surveyData.session == temp.session);
    if 1 < length(ac) | 0 == length(ac)
        disp(sprintf('More than one or zero ac for %d_%d_%d',temp.patient,...
            temp.condition, temp.session));
    else
        if 7 == ac
            disp(sprintf('ac=7 for %d_%d_%d',temp.patient, ...
                temp.condition, temp.session));
        else
            tt = acLables(ac);
            labels{P,1} = tt{1};
        end
    end
end
multipleLabels.label = labels;
end

