function [ trainingSet ] = createTrainingSet( fileList, ...
                                             trainingToTestingRatio...
                                        , numberToNotInclude, returnList )
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
%           numberToNotInclude      :           the number of labels from
%                                               the end to not include,
%                                               whenever we are dealing
%                                               with label vectors in
%                                               feature files we MUST
%                                               remove them from the
%                                               training set as the script
%                                               for fitting the gaussians
%                                               does not do any processing
%                                               on the input file (training
%                                               set).
% 
%   Output:
%           trainingSet             :           the training set is
%                                               returned
% 

if 3 == nargin
    returnList = false;
elseif 2 == nargin
    returnList = false;
    numberToNotInclude = 0;
end
trainingSetFile = datasample(fileList,floor(...
                    trainingToTestingRatio*length(fileList)), 'REPLACE',...
                    false);
if returnList
    trainingSet = trainingSetFile;
    return;
else
    if 0 == numberToNotInclude
        trainingSet = combineFiles(trainingSetFile);
    else
        trainingSet = combineFiles(trainingSetFile, {}, true, ...
            numberToNotInclude);
    end
end
end

