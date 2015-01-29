% Ryan Brummet 
% University of Iowa
%
% Builds a dataset for each response that can be passed to surveySVMFunc
%
% Params:
%   string: zdataLocation - location of the raw dataset to be used to
%                             build response datasets
%   string: zsaveLocation - location to save the response datasets
%   int: zminNumberSamples - gives the minimum number of samples each
%                            subject must have for their samples to be
%                            included
%   bool: zremove99 - if true condition 99 samples are removed

function [ ] = shabihPatchFunc( zdataLocation, zsaveLocation, zminNumberSamples, zremove99 )
    load(zdataLocation);
    zzzzz = who;
    zzz = strcat('allData = ',zzzzz{1},';');
    eval(zzz);
    temp = zzzzz{1};
    temp = strsplit(temp,'_');
    temp = temp{3};
    frameSize = temp(1:end-2);
    
    predsToRemoveInit = {'session','starttime','endtime','appwelcome','duration','subjectbash','subjectwelcome','acSpeech','location','lat','lon','WJSHC','NoiseType','Quality','surveyPath','audioPath','startDatenums','audioDatenums','patientCondition','hau','hapq'};
    predsToRemoveBeforeSave = {'listening','userinitiated','oneAudioWithMoreSurvey','afterNewApp','foundFeatures'};
    responsesToExtract = {'sp','le','ld','ld2','lcl','ap','qol','im','st'};
    allData(:,predsToRemoveInit) = [];
    allData = allData(allData.foundFeatures == true,:);
    allData(allData.oneAudioWithMoreSurvey == 1,:) = [];
    nanPredictors = {'tf','vc','tl','nl','rs','cp'};
    
    for k = 1 : size(responsesToExtract,2)
        dataTable = allData;
        temp = responsesToExtract;
        temp(strcmp(temp,responsesToExtract{k})) = [];
        dataTable(:,temp) = [];
        dataTable(isnan(dataTable.(responsesToExtract{k})),:) = [];
        dataTable((~dataTable.afterNewApp) & (dataTable.(responsesToExtract{k}) == 50),:) = [];
        if strcmp(responsesToExtract{k},'le')
            dataTable.le = 100 - dataTable.le;
        end
        if strcmp(responsesToExtract{k},'ap')
            dataTable.ap = 100 - dataTable.ap;
        end
        dataTable = dataTable(strcmp(dataTable.userinitiated,'false') | strcmp(dataTable.listening,'true'),:);
        [dataTable] = removeNonQualUsers(dataTable,zminNumberSamples);
        %convert predictor NaN values to 0
        for j = 1 : size(nanPredictors,2)
            temp = dataTable.(nanPredictors{j});
            temp(isnan(temp)) = 0;
            dataTable.(nanPredictors{j}) = temp;
        end
        dataTable(:,predsToRemoveBeforeSave) = [];
        
        if zremove99
            conditionVals = dataTable.condition;
            temp = conditionVals == 99;
            dataTable(temp,:) = [];
        end
        
        temp = dataTable(:,responsesToExtract{k});
        dataTable.(responsesToExtract{k}) = [];
        dataTable = [dataTable,temp];
        
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
        save(strcat(zsaveLocation,responsesToExtract{k},frameSize),'dataTable');
        clearvars -except k dataLocation zsaveLocation zminNumberSamples zremove99 frameSize predsToRemoveBeforeSave responsesToExtract allData nanPredictors
    end

end

