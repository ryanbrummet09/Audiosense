% NOTICE.  IF YOU INCLUDE A PREDICTOR THAT IS CATEGORICAL IN 'toRemove' DO
% NOT INCLUDE IT IN 'catPreds'.  ONCE A PREDICTOR IS REMOVED, IT IS
% REMOVED.  THUS INCLUDING A REMOVED VARIABLE IN 'catPreds' WILL RESULT IN
% AN ERROR.  THIS ISSUE DOES NOT AFFECT 'zeroPreds'.

close all;
clear;
clc;
inputStruct = struct;
inputStruct.libLocation = '/Users/ryanbrummet/Documents/MATLAB/Extensions';
inputStruct.libToUse = 1;
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/SurveyStuff/Results/temp';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/spSurvey.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
inputStruct.kernel = 0;    % use 11, 12, or 13 for libLinear  %use 0-3 for libSVM
%inputStruct.toRemoveCompletely = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.toRemoveModel = {'patient'};  % patient, age, snrLeft, snrRight
% if a variable is in catPreds it cannot be in either toRemoveModel or
% toRemoveCompletely
inputStruct.catPreds = {'condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};  %{'patient','condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.zeroPreds = {'tf','tl','vc','cp','rs','nl','condition'};
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [1];
inputStruct.startCostValues = [5];
inputStruct.allowGridSearchEdgeVals = true;
inputStruct.scaleFunc = @minMaxScaling;  %@zScoreScaling or @minMaxScaling
inputStruct.scaleLower = 0;
inputStruct.scaleUpper = 1;

inputStruct.partitionVar = {'patient'};

[ SVMSettings, mdlStruct, errorStruct ] = buildMDLLeaveOnePred(inputStruct);
