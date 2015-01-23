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
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/Results/temp';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/sp64.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
inputStruct.kernel = 2;    % use 11, 12, or 13 for libLinear  %use 0-3 for libSVM
inputStruct.toRemove = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.catPreds = {'patient','condition'};  %{'patient','condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.zeroPreds = {'tf','tl','vc','cp','rs','nl','condition'};
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [.001,.01];
inputStruct.startCostValues = [1,10];
inputStruct.allowGridSearchEdgeVals = true;
inputStruct.scaleFunc = @zScoreScaling;  %@zScoreScaling or @minMaxScaling
inputStruct.scaleLower = 0;
inputStruct.scaleUpper = 1;

[ SVMSettings, mdlStruct, errorStruct ] = buildPoolDataMDL(inputStruct);