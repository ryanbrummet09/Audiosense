function [ trainingSet, testingSet ] = createTrainingTestingSet( ...
                                        fileList, trainingToTestingRatio...
                                        , returnList)
%CREATETRAININGTESTINGSET creates training and testing sets
%   Input:
%           fileList                :           list of all the feature 
%                                               files
%           trainingToTestingRatio  :           ratio of the size of
%                                               training set and the
%                                               testing set
%           returnList              :           this is an optional flag,
%                                               if set to true, this
%                                               function returns the list
%                                               of files that are supposed
%                                               to be in the training and
%                                               testing sets
% 
%   Output:
%           trainingSet             :           the training set 
if 2 == nargin
    returnList = false;
end
[trainingSetFile,idx] = datasample(fileList,floor(...
                    trainingToTestingRatio*length(fileList)), 'REPLACE',...
                    false);
toKeep = true(length(fileList),1);
for P=1:length(idx)
    toKeep(idx(P)) = false;
end
testingSetFile = fileList(toKeep);
if returnList
    trainingSet = trainingSetFile;
    testingSet = testingSetFile;
    return;
else
    trainingSet = combineFiles(trainingSetFile);
    testingSet = combineFiles(testingSetFile);
end
end

