close all;
clear;
clc;

zdataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/surveyWithAudioDemo/surveyDataset_jan14_128ms_demo.mat';
zsaveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/';
zminNumberSamples = 10;
zremove99 = true;

shabihPatchFunc( zdataLocation, zsaveLocation, zminNumberSamples, zremove99 );