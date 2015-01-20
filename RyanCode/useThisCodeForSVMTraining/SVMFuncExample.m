close all;
clear;
clc;
inputStruct = struct;
inputStruct.libSVMLibLocation = '/Users/ryanbrummet/Documents/MATLAB/Extensions';
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/SurveyStuff/Results/temp';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/spSurvey.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
%inputStruct.kernal = 0;
%inputStruct.toRemove = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [.01];
inputStruct.startCostValues = [1000];
inputStruct.allowGridSearchEdgeVals = true;

[ SVMSettings, mdlStruct, errorStruct ] = SVMFunc( inputStruct );

