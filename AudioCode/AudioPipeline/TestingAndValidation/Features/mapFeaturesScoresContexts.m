function [ surveyDataset ] = mapFeaturesScoresContexts( surveyDataset, ...
    audioFileList, mfccCoff, statisticFunctionHandle );
%MAPFEATURESSCORESCONTEXTS maps the audio features to the survey data
%   Input:
%           surveyDataset           :       dataset containing all
%                                           information from the survey
%           audioFileList           :       list of audio files, each row
%                                           is the full path to an audio
%                                           file
%           mfccCoff                :       number of mfcc's used excluding
%                                           the 0th cofficient
%           statisticFunctionHandle :       the function handle for the
%                                           statistic we need to compute,
%                                           right now we only support
%                                           @median (default), @mean, @var,
%                                           @kurtosis, and @skewness.
% 
%   Output:
%           surveyDataset           :       modified survey dataset, this
%                                           includes information from the
%                                           aggregated audio features as
%                                           well

n = length(audioFileList);
temp = load(audioFileList{1});
temp = temp.var;
[r, c] = size(temp);
aggregatedFeatures = nan(n,c-3);
%% get aggregated audio features
disp('Getting aggregated features');
for P=1:length(audioFileList)
    if 0 == mod(P,100)
        disp(sprintf('Done %d/%d',P,n));
    end
    aggregatedFeatures(P,:) = aggregateAudioFeatures(audioFileList{P},...
        statisticFunctionHandle);
end
save('dataVariables/agF','aggregatedFeatures');
disp('Done all!');
%% make additions to the dataset
n = length(surveyDataset);
newEntries = nan(n,1);
disp('Adding audio features to dataset');
surveyDataset.ZCR = newEntries; surveyDataset.RMS = newEntries;
surveyDataset.Entropy = newEntries; surveyDataset.SRF = newEntries;
for P=0:1:mfccCoff
    s = sprintf('surveyDataset.mfcc%d=newEntries;',P);
    eval(s);
end
disp('matching survey features and audio features');
for P = 1:n
    temp = surveyDataset(P,:);
    p = temp.patient;   c = temp.condition;     s = temp.session;
    features = aggregatedFeatures(aggregatedFeatures(:,1)==p & ...
                                  aggregatedFeatures(:,2)==c & ...
                                  aggregatedFeatures(:,3)==s,4:end);
    if isempty(features)
        disp(sprintf('Could not find P=%d C=%d S=%d',p,c,s));
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
        surveyDataset(P,:) = temp;
    end
end
end

