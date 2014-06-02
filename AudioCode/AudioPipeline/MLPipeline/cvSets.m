function [ cvSet ] = cvSets( originalFileList, numberOfFolds )
%CVSETS Generate the cross validation folds for input file list
%   This function generates the CV sets for the list of files given as
%   input. There are a three assumptions made here:
%   1.  the file list would be a cell array of strings
%   2.  the file list would contain only one column, each row would
%       contain the name of the file
%   3.  the list contains full paths for each file
%   Input:
%           originalFileList    :   the input list of files
%           numberOfFolds       :   the number of folds required for cross
%                                   validation
%   Output:
%           cvSet               :   a cell array containing the cross
%                                   validation sets

cvSet = cell(numberOfFolds,1);
numberOfFiles = length(originalFileList);
if numberOfFiles <= numberOfFolds
    error('audioPipeline:cvSets','Number of folds > number of files');
    return;
end
%% Add the patient ID to the file list
originalFileList = addPID(originalFileList);
classes = unique(cell2mat(originalFileList(:,2)));
%% Generate the folds 
folds = crossvalind('kfold',cell2mat(originalFileList(:,2)),...
    numberOfFolds,'Classes',classes);

for P=1:numberOfFiles
    K = folds(P);
    temp = cvSet{K,1};
    temp{end+1,1} = originalFileList{P,1};
    cvSet{K,1} = temp;
end

