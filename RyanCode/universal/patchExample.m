close all;
clear;
clc;

zdataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/surveyWithFeature/surveyDataset_jan14_128ms.mat';
zsaveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/';
zminNumberSamples = 10;
zremove99 = true;

shabihPatchFunc( zdataLocation, zsaveLocation, zminNumberSamples, zremove99 );