% Ryan Brummet
% University of Iowa
%
% Extracts folds from the given dataset using the given seed value.  This
% duplicates the folds that are created by the SVM script.  The function
% works by saving each fold that is calculated to the designated location.
% The naming convention is outerFoldA where A is a number indicating the
% specific fold.  Furthormore innerFoldAB is used to describe inner folds
% where A indicates the one fold that IS NOT PRESENT in innerFoldAB
% (samples from outerFoldA are not in innerFoldAB).  B is used to indicate
% the particular fold of innerFoldAB.  This script will need to be run for
% each response.
%
% Params:
%   string: datasetLocation - location of dataset to retrieve folds from
%   int: seed - seed value used to build folds
%   cell array: groupVars - gives predictors used to stratify folds
%   int: crossValFolds - number of folds used
%   string: saveLocation - location to save folds.  Include a slash at the
%                          end of the string.
% Return
%   no Return
    
function [ ] = produceIndvSets( datasetLocation, seed, crossValFolds, groupVars, saveLocation )
    load(datasetLocation);
    
    rng(seed);
    
    cvVar = zeros(size(dataTable,1),1);
    for cs = 0 : size(groupVars,2) - 1
        if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
            if strcmp(char(groupVars{cs + 1}),'patient')
                cvVar = cvVar + dataTable.patient;
            else
                cvVar = cvVar + dataTable.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
            end
        else
            cvVar = cvVar + dataTable.(groupVars{cs + 1}) * 10 ^ (-cs);
        end
    end
    dataTable.cvVar = cvVar;
    outerCV = cvpartition(dataTable.cvVar,'kfold',crossValFolds);
    dataTable.cvVar = [];
    
    for k = 1 : crossValFolds
        fold = dataTable(test(outerCV,k),:);
        save(strcat(saveLocation,'outerFold',num2str(k)),'fold');
        temp = dataTable(training(outerCV,k),:);
        cvVar = zeros(size(temp,1),1);
        for cs = 0 : size(groupVars,2) - 1
            if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
                if strcmp(char(groupVars{cs + 1}),'patient')
                    cvVar = cvVar + temp.patient;
                else
                    cvVar = cvVar + temp.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
                end
            else
                cvVar = cvVar + temp.(groupVars{cs + 1}) * 10 ^ (-cs);
            end
        end
        temp.cvVar = cvVar;
        innerCV = cvpartition(temp.cvVar,'kfold',crossValFolds);
        temp.cvVar = [];
        
        for j = 1 : crossValFolds
           fold = temp(test(innerCV,j),:);
           save(strcat(saveLocation,'innerFold',num2str(k),num2str(j)),'fold');
        end
    end
end

