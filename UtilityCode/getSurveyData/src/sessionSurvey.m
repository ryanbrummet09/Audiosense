function [ session ] = sessionSurvey( session, survey )
%SESSIONSURVEY makes the session variable consistent
%   Input:
%           session : the session variable from the table
%           survey  : the survey variable from the table
% 
%   Output:
%           session : the session survey with the correct values
% 
%   Usage:
%           suppose the table is ipDataset
%           session = sessionSurvey(ipDataset.session, ipDataset.survey);
if iscell(survey)
    nsurvey = zeros(length(survey),1);
    for P=1:length(survey)
        if strcmp('',survey{P})
            nsurvey(P) = nan;
        else
            nsurvey(P) = str2num(survey{P});
        end
    end
    survey = nsurvey;
end
for P=1:length(survey)
    if ~isnan(survey(P))
        session(P) = survey(P);
    end
end
end

