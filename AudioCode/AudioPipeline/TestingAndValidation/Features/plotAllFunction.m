function [varargout] = plotAllFunction(SurveyDS,attList,boxPlotFlag,...
    DSType, patientID)
%PLOTALLFUNCTION Summary of this function goes here
%   Detailed explanation goes here

opTable = table;
for P=1:length(attList)
    cmdOutcome = ...
        sprintf('plotWithOutcomes(SurveyDS.%s,''%s'',SurveyDS,%d,''%s'',''%s'');',...
        attList{P},attList{P},boxPlotFlag,DSType,patientID);
    cmdContext = ...
        sprintf('plotWithContexts(SurveyDS.%s,''%s'',SurveyDS,''%s'',''%s'');',...
        attList{P},attList{P},patientID,DSType);
    tempTable = eval(cmdOutcome);
    if 0 ~= height(tempTable)
        opTable = [opTable; tempTable];
    end
    eval(cmdContext);
end
varargout{1} = opTable;
end

