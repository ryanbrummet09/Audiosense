close all;
clear;
clc;

inputStruct = struct;
inputStruct.libSVMLibLocation = '/Users/ryanbrummet/Documents/MATLAB/Extensions';
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/SurveyStuff/Results/tempRBF';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/spSurvey.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
inputStruct.toRemove = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [1];
inputStruct.startCostValues = [1,10,100,1000,10000,50000];
inputStruct.allowGridSearchEdgeVals = true;

[ SVMSettings, mdlStruct, absErrorStruct ] = SVMFunc( inputStruct );
