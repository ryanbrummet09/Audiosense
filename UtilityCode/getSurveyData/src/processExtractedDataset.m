function [ ipDataset ] = processExtractedDataset( ipDataset )
%PROCESSEXTRACTEDDATASET process the extracted dataset
%   Input/Output:
%           ipDataset : dataset extracted from python script

%% remove users who have withdrawn
withdrawnUsers = [17, 23, 30, 49];
for P=1:length(withdrawnUsers)
    ipDataset = ipDataset(ipDataset~=withdrawnUsers(P),:);
end
%% put the correct session value
session = sessionSurvey(ipDataset.session, ipDataset.survey);
ipDataset.session = session;
ipDataset.survey = [];

%% identify shared audio files
ipDataset = removeMultipleAudio(ipDataset);

%% get the files that were created after the new app
dns = getDatenums(ipDataset.starttime);
ipDataset.startDatenums = dns;
toCheckDN = '2014-01-30';
toCheckDN = datenum(toCheckDN, 'yyyy-mm-dd');
afterNewApp = dns > toCheckDN;
ipDataset.afterNewApp = afterNewApp;
dns = getDatenums(ipDataset.audioPath, true);
ipDataset.audioDatenums = dns;

end

