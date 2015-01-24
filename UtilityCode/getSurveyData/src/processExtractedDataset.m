function [ ipDataset ] = processExtractedDataset( ipDataset, xlsFilePath )
%PROCESSEXTRACTEDDATASET process the extracted dataset
%   Input/Output:
%           ipDataset       :   dataset extracted from python script
%           xlsFilePath     :   path to the excel file containing the
%                               sheets 'Demographics', and 'QuickSin'

if 1 == nargin
    xlsFilePath = '';
end
%% remove users who have withdrawn
disp('Removing patients who have withdrawn from the study:');
withdrawnUsers = [17, 23, 30, 49];
for P=1:length(withdrawnUsers)
    ipDataset = ipDataset(ipDataset.patient~=withdrawnUsers(P),:);
    disp(sprintf('Removed patient %d', withdrawnUsers(P)));
end
%% put the correct session value
disp('Correcting session and survey values');
session = sessionSurvey(ipDataset.session, ipDataset.survey);
ipDataset.session = session;
ipDataset.survey = [];

%% identify shared audio files
disp('Identifying audio files that are shared between surveys');
ipDataset = removeMultipleAudio(ipDataset);

%% get the files that were created after the new app
disp('Identifying files that were created after January 30, 2014');
dns = getDatenums(ipDataset.starttime);
ipDataset.startDatenums = dns;
toCheckDN = '2014-01-30';
toCheckDN = datenum(toCheckDN, 'yyyy-mm-dd');
afterNewApp = dns > toCheckDN;
ipDataset.afterNewApp = afterNewApp;
dns = getDatenums(ipDataset.audioPath, true);
ipDataset.audioDatenums = dns;

%% get the demographic data and the SIN Test data
if ~isempty(xlsFilePath)
    disp('Extracting demographic and SIN Test data');
    ipDataset = addDemograhicsToExistingDataset(ipDataset, xlsFilePath);
end
disp('Done');
end

