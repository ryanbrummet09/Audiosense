function [ combinedDataset ] = combineAudioFeaturesWithSurvey( surveyDataset,...
                                                        audioDataset )
%COMBINEAUDIOFEATURESWITHSURVEY Summary of this function goes here
%   Detailed explanation goes here

ff = false(height(surveyDataset),1);
mzff = false(height(surveyDataset),1);
h = height(surveyDataset);
fnAudio = audioDataset.Properties.VariableNames;
fArray = table2array(audioDataset);
[~,c] = size(fArray);
nFArray = zeros(h,c-4);
nFArray = nFArray - 1;
for P=1:h
    tempT = surveyDataset(P,:);
    audioFeatures = fArray(...
        fArray(:,end-3)==tempT.patient & ...
        fArray(:,end-2)==tempT.condition & ...
        fArray(:,end-1)==tempT.session & ...
        fArray(:,end)==tempT.audioDatenums,1:end-4);
    [rt,~] = size(audioFeatures);
    if 1 == rt
        nFArray(P,:) = audioFeatures;
        ff(P) = true;
    else
        mzff(P) = true;
    end
end
tempAudioDataset = array2table(nFArray);
tempAudioDataset.Properties.VariableNames = fnAudio(1:end-4);
surveyDataset.foundFeatures = ff;
combinedDataset = [surveyDataset tempAudioDataset];
end

