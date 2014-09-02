function [ featureTable ] = HigherLevelFeatures( dataStruct )
%HIGHERLEVELFEATURES extract higher level features
%   Input:
%           dataStruct      :       data structure containing the details
%                                   of the data and the data itself. It
%                                   contains the following fields, viz. pid
%                                   which indicates the patientID, cid
%                                   represents the conditionID, sid
%                                   represents the session ID, sno
%                                   indicates the internal file identifier,
%                                   features represent the matrix
%                                   containing the features
% 
%   Output:
%           featureTable    :       the table contains the higher level
%                                   features
featureList = {'minV','maxV',...
    'stdV','median','1qr','3qr','iqr','skewnessV','kurtosisV',...
    'noOfPeaks','meanAmpPeaks'};
dataFeatures = {'rms', 'zcr', 'mfcc0', 'mfcc1', 'mfcc2', 'mfcc3', ...
    'mfcc4', 'mfcc5', 'mfcc6', 'mfcc7', 'mfcc8', 'mfcc9', 'mfcc10', ...
    'mfcc11', 'mfcc12','srf25','srf50','srf75','srf90','sflux',...
    'scentroid','sentropy'}; 
data = dataStruct.features;
featureVector = {};
featureVariableNames = {'patient','condition','session','sno'};
for P=1:length(dataFeatures)
    featureN = dataFeatures{P};
    for Q=1:length(featureList)
        temp = sprintf('%s_%s',featureN,featureList{Q});
        featureVariableNames{1,end+1} = temp;
    end
end
featureVector{1,end+1} = dataStruct.pid;
featureVector{1,end+1} = dataStruct.cid;
featureVector{1,end+1} = dataStruct.sid;
featureVector{1,end+1} = dataStruct.sno;
[r,c] = size(data);
% per feature extract the high level features
for P=1:c
    featureColumn = data(:,P);
%     min
    featureVector{1,end+1} = min(featureColumn);
%     max
    featureVector{1,end+1} = max(featureColumn);
%     standard deviation
    featureVector{1,end+1} = std(featureColumn);
%     median
    featureVector{1,end+1} = median(featureColumn);
%     1st Quartile
    featureVector{1,end+1} = prctile(featureColumn,25);
%     3rd Quartile
    featureVector{1,end+1} = prctile(featureColumn,75);
%     IQR
    featureVector{1,end+1} = ...
                             prctile(featureColumn,75) - ...
                             prctile(featureColumn,25);
%     skewness
    featureVector{1,end+1} = skewness(featureColumn);
%     kurtosis
    featureVector{1,end+1} = kurtosis(featureColumn);
%     number of peaks
    [peakAmps, peakLocs] = findpeaks(abs(featureColumn),'threshold',...
                                        median(abs(featureColumn)));
    featureVector{1,end+1} = length(peakAmps);
%     mean amplitude of peaks
    featureVector{1,end+1} = mean(peakAmps);
end
featureVector{1,end+1} = dataStruct.label;
featureTable = table;
featureTable = cell2table(featureVector);
featureVariableNames{1,end+1} = 'label';
featureTable.Properties.VariableNames = featureVariableNames;
end