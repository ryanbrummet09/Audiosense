function [ trainingSet ] = createTrainingSet( fileList, ...
                                             trainingToTestingRatio...
                                        , returnList )
%CREATETRAININGSET picks out the files for creating the GMMs
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
%           trainingSet             :           the training set is
%                                               returned
% 

if 2 == nargin
    returnList = false;
end
trainingSetFile = datasample(fileList,floor(...
                    trainingToTestingRatio*length(fileList)), 'REPLACE',...
                    false);
if returnList
    trainingSet = trainingSetFile;
    return;
else
    trainingSet = combineFiles(trainingSetFile);
end
end

