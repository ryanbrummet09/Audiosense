% NOTICE.  IF YOU INCLUDE A PREDICTOR THAT IS CATEGORICAL IN 'toRemove' DO
% NOT INCLUDE IT IN 'catPreds'.  ONCE A PREDICTOR IS REMOVED, IT IS
% REMOVED.  THUS INCLUDING A REMOVED VARIABLE IN 'catPreds' WILL RESULT IN
% AN ERROR.  THIS ISSUE DOES NOT AFFECT 'zeroPreds'.

close all;
clear;
clc;
inputStruct = struct;
inputStruct.dirsToPath = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/'};
inputStruct.saveLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/SurveyStuff/Results/temp';
inputStruct.dataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/ExtractedResponseSets/spSurvey.mat';
inputStruct.response = {'sp'};
inputStruct.numCores = 2;
%inputStruct.toRemoveCompletely = {'ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.toRemoveModel = {'age', 'snrLeft', 'snrRight'};  % patient, age, snrLeft, snrRight
% if a variable is in catPreds it cannot be in either toRemoveModel or
% toRemoveCompletely
inputStruct.catPreds = {'patient','condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};  %{'patient','condition','ac','lc','tf','tl','vc','cp','rs','nz','nl'};
inputStruct.makePlot = true;
inputStruct.groupVars = {'patient','condition'};
inputStruct.scaleFunc = @minMaxScaling;  %@zScoreScaling or @minMaxScaling
inputStruct.scaleLower = 0;
inputStruct.scaleUpper = 1;

modelSpec = struct;
modelSpec.mdlType = 'fitlme';   %'fitlm', 'fitlme', 'fitglm'
modelSpec.evalAllOptions = true;
modelSpec.mdlForm = 'sp ~ 1 + condition + (1 | patient)';   %'constant', 'linear', 'interactions', 'purequadratic', 'quadratic', 'polyijk', and user specified using wilkinson notation
modelSpec.robust = {'off'};    %'andrews', 'bisquare', 'cauchy', 'fair', 'huber', 'logistic', 'ols', 'talwar', 'welsch', and 'off'
% IT IS ASSUMED THAT THERE IS ONLY ONE MIXED EFFECT VARIABLE.
modelSpec.covariancePattern = {'FullCholesky'};  %'FullCholesky', 'Full', 'Diagonal', 'Isotropic', or 'CompSymm'
modelSpec.fitMethod = {'ML'};   %'ML', 'REML'
modelSpec.optimizer = {'quasinewton'}; %'quasinewton', 'fminunc'
modelSpec.distribution = {'normal'};   %'normal', 'poisson', 'gamma', 'inverse gaussian'
modelSpec.link = {'identity'};   %'identity', 'log', 'logit', 'probit', 'comploglog', and 'reciprocal'

[ Settings, mdlStruct, errorStruct ] = buildMatlabPoolDataMDL(inputStruct, modelSpec);

