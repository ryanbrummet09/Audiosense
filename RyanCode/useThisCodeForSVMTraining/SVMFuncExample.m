close all;
clear;
clc;
inputStruct = struct;
inputStruct.libLocation = '/Users/ryanbrummet/Documents/MATLAB/Extensions';
inputStruct.libToUse = 1;
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/SurveyStuff/Results/stSurveyResults';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/stSurvey.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
inputStruct.kernel = 2;    % use 11, 12, or 13 for libLinear  %use 0-3 for libSVM
%inputStruct.toRemove = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [.001,.01,.1];
inputStruct.startCostValues = [10000,100000,500000];
inputStruct.allowGridSearchEdgeVals = true;

[ SVMSettings, mdlStruct, errorStruct ] = SVMFunc( inputStruct );

