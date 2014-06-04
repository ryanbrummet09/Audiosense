function [ surveyDataset ] = mapFeaturesScoresContexts( surveyDataset, ...
    audioFileList, mfccCoff, statisticFunctionHandle );
%MAPFEATURESSCORESCONTEXTS Summary of this function goes here
%   Detailed explanation goes here

n = length(audioFileList);
temp = load(audioFileList{1});
temp = temp.var;
[r, c] = size(temp);
aggregatedFeatures = nan(n,c-3);
%% get aggregated audio features
for P=1:length(audioFileList)
    aggregatedFeatures(P,:) = aggregateAudioFeatures(audioFileList{P},...
        statisticFunctionHandle);
end
%% make additions to the dataset
n = length(surveyDataset);
newEntries = nan(n,1);
surveyDataset.ZCR = newEntries; surveyDataset.RMS = newEntries;
surveyDataset.Entropy = newEntries; surveyDataset.SRF = newEntries;
for P=0:1:mfccCoff
    s = sprintf('surveyDataset.mfcc%d=newEntries;',P);
    eval(s);
end
for P = 1:n
    temp = surveyDataset(P,:);
    p = temp.patient;   c = temp.condition;     s = temp.session;
    features = aggregatedFeatures(aggregatedFeatures(:,1)==p & ...
                                  aggregatedFeatures(:,2)==c & ...
                                  aggregatedFeatures(:,3)==s,4:end);
    if isempty(features)
        temp.ZCR = nan; temp.RMS = nan; temp.Entropy = nan;
        temp.SRF = nan;
        for Q=0:1:mfccCoff
            s = sprintf('temp.mfcc%d=nan;',Q);
            eval(s);
        end
        surveyDataset(P,:) = temp;
    else
        temp.ZCR = features(1,1);   temp.RMS = features(1,2);
        temp.Entropy = features(1,3); temp.SRF = features(1,4);
        [u v] = size(features);
        for Q=5:1:v
            s = sprintf('temp.mfcc%d=features(1,Q);',Q-5);
            eval(s);
        end
    end
end
end

