%Ryan Brummet
%University of Iowa

function [ normData, AVG, STD ] = normalizeDataAndFindNormVals( allData, trainData, attributes, innerCV, innerFolds, norm )
    %normalizes data that is passed to it using global normalization or
    %user normalization
    
    %normalize globally
    if norm == 2
        %find normalization values for each attribute and normalize
        for k = 1 : size(attributes,2)
            %find norm values.  AVG and STD are "two" dimensional so that
            %the variables will have the same output form regardless of
            %global or user norm (user norm requires avg and std per user)
            AVG(1,k) = nanmean(table2array(trainData(training(innerCV,innerFolds),attributes{k})));
            STD(1,k) = nanstd(table2array(trainData(training(innerCV,innerFolds),attributes{k})));
            
            %apply normalization values to attribute
            allData.(attributes{k}) = (allData.(attributes{k}) - AVG(1,k)) / STD(1,k);
        end
        
    %normalize by user
    elseif norm == 3
        %find unique users
        subjectIDs = unique(allData.patient);
        
        %iterate through each patient
        for s = 1 : size(subjectIDs,1)
            %find trainingSet
            trainingSet = trainData(training(innerCV,innerFolds),:);
            
            %find user samples in training set
            subjectTrainingSamples = (trainingSet.patient == subjectIDs(s));
            
            %find user samples in the whole data set
            subjectSamples = (allData.patient == subjectIDs(s));
            
            %for each patient, iterate through each attribute and find the
            %norm values (avg and std of samples in training set)
            for k = 1 : size(attributes,2)
                AVG(s,k) = nanmean(table2array(trainingSet(subjectTrainingSamples,attributes{k})));
                STD(s,k) = nanstd(table2array(trainingSet(subjectTrainingSamples,attributes{k})));
                
                %apply normalization values to attributes in subject
                %samples in training and testing sets
                allData(subjectSamples,attributes{k}) = ...
                    array2table((table2array(allData(subjectSamples,attributes{k})) - AVG(s,k)) / STD(s,k));
            end
        end
        
    end
    
    %scale all data
    for attr = 1 : size(attributes,2)
        %assign inf values to nan
        if size(allData(isinf(table2array(allData(:,attributes{attr}))),attributes{attr}),1) ~= 0
            temp = size(allData(isinf(table2array(allData(:,attributes{attr}))),attributes{attr}),1);
            allData(isinf(table2array(allData(:,attributes{attr}))),attributes{attr}).(attributes{attr}) = NaN(temp,1);
        end
        
        allData.(attributes{attr}) = 100 * (allData.(attributes{attr}) - ...
            nanmin(allData.(attributes{attr}))) / (nanmax(allData.(attributes{attr})) - ...
            nanmin(allData.(attributes{attr}))); 
    end
    
    %return all data
    normData = allData;
end

