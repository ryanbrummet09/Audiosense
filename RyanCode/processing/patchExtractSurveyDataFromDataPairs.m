% Ryan Brummet
% University of Iowa

% builds datasets for sp le ld ld2 lcl ap qol im and st

close all;
clear;
clc;

Fx = @(x) any(isnan(x));

saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/responseSets/';

predictorsToExtract = {'patient','condition','ac','lc','tl','tf','vc','nz','nl','cp','rs','session','listening','userinitiated','afterNewApp','audioPath'};
responsesToExtract = {'sp','le','ld','ld2','lcl','ap','qol','im','st'};

% gives the values used to predict responses using the surveys that might
% be NaN
nanPredictors = {'tf','vc','tl','nl','rs','cp'};

predictorsToSave = {'patient','condition','ac','lc','tl','tf','vc','nz','nl','cp','rs','session','audioName'};

minNumberSamples = 10;

load('/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/ShabihExtractedDataTable.mat');

allDataShabihExtracted(allDataShabihExtracted.oneAudioWithMoreSurvey == 1,:) = [];

for k = 1 : size(responsesToExtract,2)
    dataTable = allDataShabihExtracted(:,[predictorsToExtract,responsesToExtract(k)]);
    dataTable(isnan(dataTable.(responsesToExtract{k})),:) = [];
    dataTable((~dataTable.afterNewApp) & (dataTable.(responsesToExtract{k}) == 50),:) = [];
    if strcmp(responsesToExtract{k},'le')
        dataTable.le = 100 - dataTable.le;
    end
    if strcmp(responsesToExtract{k},'ap')
        dataTable.ap = 100 - dataTable.ap;
    end
    dataTable = dataTable(strcmp(dataTable.userinitiated,'false') | strcmp(dataTable.listening,'true'),:);
    [dataTable] = removeNonQualUsers(dataTable,minNumberSamples);
    %convert predictor NaN values to 0
    for j = 1 : size(nanPredictors,2)
        temp = dataTable.(nanPredictors{j});
        temp(isnan(temp)) = 0;
        dataTable.(nanPredictors{j}) = temp;
    end
    
    for j = 1 : size(dataTable,1)
        temp = strsplit(dataTable.audioPath{j},'/');
        audioNames(j) = temp(11);
    end
    audioNames = audioNames';
    temp = dataTable(:,responsesToExtract(k));
    dataTable(:,responsesToExtract(k)) = [];
    dataTable(:,'audioPath') = [];
    dataTable.audioName = audioNames;
    dataTable = [dataTable,temp];
    dataTable = dataTable(:,[predictorsToSave,responsesToExtract{k}]);
    
    conditionVals = dataTable.condition;
    for j = 1 : size(conditionVals,1)
        if conditionVals(j) == 21
            conditionVals(j) = 7;
        elseif conditionVals(j) == 22
            conditionVals(j) = 8;
        elseif conditionVals(j) == 23
            conditionVals(j) = 9;
        elseif conditionVals(j) == 24
            conditionVals(j) = 10;
        elseif conditionVals(j) == 99
            conditionVals(j) = 0; 
        end
    end
    dataTable.condition = conditionVals;
    
    save(strcat(saveLocation,responsesToExtract{k}),'dataTable');
    clearvars -except k saveLocation predictorsToExtract responsesToExtract nanPredictors predictorsToSave minNumberSamples allDataShabihExtracted
end

