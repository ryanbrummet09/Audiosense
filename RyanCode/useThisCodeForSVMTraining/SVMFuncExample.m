close all;
clear;
clc;

inputStruct = struct;
inputStruct.libSVMLibLocation = '/Users/ryanbrummet/Documents/MATLAB/Extensions';
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/Results/';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/temp.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.maxIterCount = 1;
inputStruct.startGammaValues = [.000001,.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000,500000];
inputStruct.startCostValues = [.000001,.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000,500000];
inputStruct.allowGridSearchEdgeVals = true;

[ SVMSettings, absError ] = SVMFunc( inputStruct );
