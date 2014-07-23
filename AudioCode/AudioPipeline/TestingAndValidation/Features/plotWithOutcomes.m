function [varargout] = plotWithOutcomes( theInput,labelForAxis,surveyDS,boxplotFlag, ...
    DSType, patientID)
%PLOTWITHOUTCOMES Summary of this function goes here
%   Detailed explanation goes here
if 4 == nargin
    patientID = 'All';
    DSType = 'Not Supplied';
elseif 5 == nargin
    patientID = 'All';
end
opTable = table;
val = plotCorrelation(theInput,surveyDS.le,labelForAxis,'LE','subplot(3,2,1);'...
    ,false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
val = plotCorrelation(theInput,surveyDS.sp,labelForAxis,'SP','subplot(3,2,2);'...
    ,false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
val = plotCorrelation(theInput,surveyDS.st,labelForAxis,'ST','subplot(3,2,3);'...
    ,false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
val = plotCorrelation(theInput,surveyDS.lcl,labelForAxis,'LCL',...
    'subplot(3,2,4);',false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
val = plotCorrelation(theInput,surveyDS.ld2,labelForAxis,'LD2',...
    'subplot(3,2,5);',false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
val = plotCorrelation(theInput,surveyDS.ap,labelForAxis,'AP',...
    'subplot(3,2,6);',false,true,boxplotFlag,patientID,DSType);
if 0 ~= height(val)
    opTable = [opTable;val];
end
varargout{1} = opTable;
if ~boxplotFlag
    savefig(sprintf('plots/latest/%sScatterOutcomes%s%s',labelForAxis,...
        patientID,DSType));
else
    savefig(sprintf('plots/latest/%sOutcomesBox%s%s',labelForAxis,...
        patientID,DSType));
end
close all;
end

