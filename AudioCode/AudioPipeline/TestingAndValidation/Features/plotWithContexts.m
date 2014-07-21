function plotWithContexts( theInput,labelForAxis,surveyDS,patientID,DSType)
%PLOTWITHCONTEXTS Summary of this function goes here
%   Detailed explanation goes here

if 3 == nargin
    patientID = 'All';
    DSType = 'Unknown';
elseif 4 == nargin
    DSType = 'Unknown';
end
plotCorrelationContext(surveyDS.ac,theInput,'AC',labelForAxis,...
    'subplot(3,3,1);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.lc,theInput,'LC',labelForAxis,...
    'subplot(3,3,2);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.tf,theInput,'TF',labelForAxis,...
    'subplot(3,3,3);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.vc,theInput,'VC',labelForAxis,...
    'subplot(3,3,4);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.tl,theInput,'TL',labelForAxis,...
    'subplot(3,3,5);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.nz,theInput,'NZ',labelForAxis,...
    'subplot(3,3,6);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.nl,theInput,'NL',labelForAxis,...
    'subplot(3,3,7);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.rs,theInput,'RS',labelForAxis,...
    'subplot(3,3,8);',false,false,patientID,DSType);
plotCorrelationContext(surveyDS.cp,theInput,'CP',labelForAxis,...
    'subplot(3,3,9);',false,false,patientID,DSType);
savefig(sprintf('plots/latest/%sContextsBox%s%s',labelForAxis,...
    patientID,DSType));
close all;

end

