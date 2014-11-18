function [ featureTable ] = HigherLevelFeatures( dataStruct, labelVector )
%HIGHERLEVELFEATURES extract higher level features
%   Input:
%           dataStruct      :       data structure containing the details
%                                   of the data and the data itself. It
%                                   contains the following fields, viz. pid
%                                   which indicates the patientID, cid
%                                   represents the conditionID, sid
%                                   represents the session ID, 
%                                   features represent the matrix
%                                   containing the features, in the case
%                                   when labelVector is true, then the
%                                   field label_name should contain the
%                                   actual label names for each column in
%                                   the label vector. There is an optional
%                                   flag , extras, that is used when
%                                   variable number of MFCCs, SRFs, and
%                                   subband powers are calculated.
%           labelVector     :       an optional flag indicating if the
%                                   label data structure is a vector
% 
%   Output:
%           featureTable    :       the table contains the higher level
%                                   features
if 1 == nargin
    labelVector = false;
end
featureList = {'minV','maxV',...
    'stdV','median','1qr','3qr','iqr','skewnessV','kurtosisV',...
    'noOfPeaks','meanAmpPeaks'};
if isfield(dataStruct,'extras')
    if dataStruct.extras
        noOfMFCC = dataStruct.mfcc;
        SRFs = dataStruct.srf;
        noOfSBP = dataStruct.sbp;
        dataFeatures = {'rms','zcr'};
        if noOfMFCC > 0
            for P=0:noOfMFCC
                dataFeatures{end+1} = sprintf('mfcc%d',P);
            end
        end
        if length(SRFs) > 0
            for P=1:length(SRFs)
                dataFeatures{end+1} = sprintf('srf%d',int32(SRFs(P)*100));
            end
        end
        dataFeatures{end+1} = 'sflux';
        dataFeatures{end+1} = 'scentroid';
        dataFeatures{end+1} = 'sentropy';
        if noOfSBP > 0
            for P=0:noOfSBP-1
                dataFeatures{end+1} = sprintf('sbp%d',P);
            end
        end
    else
        dataFeatures = {'rms', 'zcr', ....
            'mfcc0', 'mfcc1', 'mfcc2', 'mfcc3', 'mfcc4', 'mfcc5',...
            'mfcc6', 'mfcc7', 'mfcc8', 'mfcc9', 'mfcc10', 'mfcc11',...
            'mfcc12',....
            'srf25','srf50','srf75','srf90',...
            'sflux','scentroid','sentropy',....
            'sbp0','sbp1','sbp2','sbp3','sbp4','sbp5','sbp6','sbp7'}; 
    end
else
    dataFeatures = {'rms', 'zcr', ....
        'mfcc0', 'mfcc1', 'mfcc2', 'mfcc3', 'mfcc4', 'mfcc5',...
        'mfcc6', 'mfcc7', 'mfcc8', 'mfcc9', 'mfcc10', 'mfcc11',...
        'mfcc12',....
        'srf25','srf50','srf75','srf90',...
        'sflux','scentroid','sentropy',....
        'sbp0','sbp1','sbp2','sbp3','sbp4','sbp5','sbp6','sbp7'}; 
end
data = dataStruct.features;
featureVector = {};
featureVariableNames = {'patient','condition','session'};
featureVector{1,end+1} = dataStruct.pid;
featureVector{1,end+1} = dataStruct.cid;
featureVector{1,end+1} = dataStruct.sid;
if labelVector
    featureVector{1,end+1} = dataStruct.date;
    featureVariableNames{1,end+1} = 'date';
end
for P=1:length(dataFeatures)
    featureN = dataFeatures{P};
    for Q=1:length(featureList)
        temp = sprintf('%s_%s',featureN,featureList{Q});
        featureVariableNames{1,end+1} = temp;
    end
end
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
    [peakAmps, ~] = findpeaks(abs(featureColumn));
    featureVector{1,end+1} = length(peakAmps);
%     mean amplitude of peaks
    featureVector{1,end+1} = mean(peakAmps);
end
featureTable = table;
if ~labelVector
    featureVector{1,end+1} = dataStruct.label;
    featureVariableNames{1,end+1} = 'label';
else
    for P=1:length(dataStruct.label_name)
        featureVariableNames{1,end+1} = dataStruct.label_name{P};
    end
    [r_l,c_l] = size(dataStruct.label);
    labelV = zeros(1,c_l);
    labelV = labelV - 1;
    for P=1:r_l
        rowV = dataStruct.label(P,:);
        labelV(find(rowV == 1)) = 1;
    end
    for P=1:c_l
        featureVector{1,end+1} = labelV(P);
    end
    %featureVector{1,end+1:end+c_l} = labelV;
end
featureTable = cell2table(featureVector);
featureTable.Properties.VariableNames = featureVariableNames;
end