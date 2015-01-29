% Ryan Brummet
% University of Iowa
%
% This function is similar in nature to buildPoolDataMDL in that this
% function is exactly the same with the exception that no grid search for
% cost and gamma is run nor does this function use either libSVM or
% libLinear.  Instead this function uses specified, inbuild matlab
% functions: fitlm, fitlme, robustfit, and stepwiseglm.  Like
% buildPoolDataMDL this function takes as input a struct that contains
% information relevent to the dataset and setting up the problem.  This
% function, however, contains an additional struct modelSpec that contains
% the type of model being used as well as relevent settings.  For
% simplicity this function does not deal with optimizing the
% parallelization.  Instead, this function defaults to using outer
% parallelization.
%
% Params: 
%    struct: inputStruct
%       fields: 
%           cell array: dirsToPath - location of directories to add to
%                                    path.  Add by column NOT row.
%           string: saveLocation - location to save results; if not present
%                                  results are only returned, not saved.
%                                  Include the full name you wish to use
%                                  but do not include extension.
%           string: dataLocation - location of dataset (must be table named
%                                  dataTable saved at this .mat location)
%           cell array: response - name of the response being predicted.
%                                  If not the last column of dataTable an
%                                  error is thrown.
%           int: numCores - gives the number of cores to use for parfor.
%                           Default is 1.
%           bool: makePlot - if true a graph is created. default is true.
%                            for this to run it must also be true that
%                            crossValFolds == 5
%           cell array: groupVars - gives predictors used to stratify folds
%           int: seed - gives the seed value for the RNG
%           int: crossValFolds - gives the number of inner/outer cross
%           cellArray: toRemoveCompletely - cell array of predictor names
%                                           to completely remove.
%           cellArray: toRemoveModel - cell array of predictor names to
%                                      omit from created model(s).  This
%                                      field is primarily used to allow the
%                                      user of this function to remove a
%                                      variable from a model but still
%                                      allow it to be used for other
%                                      functions.  For example, you may
%                                      want to not include a particular
%                                      variable in a model but still use it
%                                      to stratify your dataset.  In this
%                                      case you must include the variable
%                                      in question in this field and
%                                      groupVars.  Finally, notice that all
%                                      predictor names included here must
%                                      be categorical (surveyPreds).
%           function handle: scaleFunc - scales the audio predictors according
%                                    to the passed function handle.  This
%                                    function takes as input the whole set
%                                    of audio features as once, not just
%                                    one at a time.  Notice also that
%                                    survey features are not passed, only
%                                    audio features (one does not need to
%                                    worry about inadvertently scaling
%                                    categorical survey features).  This
%                                    scaling is applied globally rather
%                                    than per training set: either inner or
%                                    outer.
%           int: scaleLower - gives the lower value of the scaling range
%                             created by scaleFunc.  default is 0.
%           int: scaleUpper - gives the upper value of the scaling range
%                             created by scaleFunc.  default is 1.
%           cell array: catPreds - gives the names of categorical
%                                  variables in dataTable.  All categorical
%                                  variables are assumed to be described
%                                  numerically (ie 1,2,3,... not
%                                  a,b,c,...).  All categorical variables
%                                  that appear here cannot be included in
%                                  toRemoveCompletely or toRemoveModel.
%   struct: modelSpec - many of this structs fields will be empty
%       fields:
%           string: mdlType - 1 for fitlm, 2 for fitlme, 3 for fitglm.  We 
%                          do not include stepwise regression as it is
%                          considered to be too expensive.  If you would
%                          like to use stepwise regression you will need to
%                          build a seperate function.  For fitlme it is
%                          assumed that there is only one mixed effect
%                          variable.
%           bool: evalAllOptions - if true for the given mdlType inner
%                                  cross validation is used to find the
%                                  optimal settings for the model (for
%                                  example distribution of the response,
%                                  link function, etc).  The default is
%                                  true.  If true settings for robust,
%                                  covariancePattern, fitMethod, and
%                                  optimizer will be ignored.
%           string: modelForm - gives the form of the model to create using
%                               wilkinson notation or a default string such
%                               as 'constant', 'interactions', etc.  For 
%                               example, y ~ x + 1 creates a model of x 
%                               with an intercept term using wilkinson
%                               notation
%           string: robust - This field is only applicable to fitle.  This
%                            parameter determines whether robust regression
%                            is used.  The default is not to use robust
%                            regression (the exception being if
%                            evalAllOptoins is true).  Options are
%                            'andrews', 'bisquare', 'cauchy', 'fair',
%                            'huber', 'logistic', 'ols', 'talwar', 'welsch'
%                            , and 'off'.
%           string: covariancePattern - Pattern of the covariance matrix of 
%                                       the random effects.  Options are,
%                                       'FullCholesky', 'Full', 'Diagonal',
%                                       'Isotropic', or 'CompSymm'.  This
%                                       field is only applicable to fitlme.
%                                        Default is 'FullCholesky'.
%           string: fitMethod - This field is only applicable to fitlme.
%                               Options are 'ML' and 'REML'.  default is
%                               'ML'
%           string: optimizer - This field is only applicable to fitlme.  
%                               Options are 'quasinewton' and 'fminunc'.
%                               We do not get so detailed as to find the 
%                               optimal params for the optimizer (for 
%                               example number of iterations, step size 
%                               tolerance, etc).  Instead we use the matlab
%                               defaults.  Default is 'quasinewton'
%           string: distribution - This field is only applicable to fitglm.
%                                  this gives the distribution of the
%                                  response variable.  Options include 
%                                  'normal', 'poisson', 'gamma', and 
%                                  'inverse gaussian'.  Matlab also gives
%                                  support for binomial distributions, but
%                                  this function does not provide support
%                                  for it.  default is 'normal'
%           string: link - This field is only applicable to fitglm.  This
%                          gives the link function used by fitglm.  Options
%                          include 'identity', 'log', 'logit', 'probit', 
%                          'comploglog', and 'reciprocal'.  default is
%                          'identity'.
% Return
%   struct: Settings
%       fields:
%           cellArray: usedRobust - optimal value or used value, for each fold
%                                   , for robust option specified in modelSpec 
%                                   (optimal value if evalAllOptions is true).
%           cellArray: usedCovariancePattern - optimal value of used value, 
%                                              for each fold, for 
%                                              covariancePattern specified in
%                                              modelSpec (optimal value if
%                                              evalAllOptions is true).
%           cellArray: usedFitMethod - optimal value or used value, for each 
%                                      fold, for fitMethod specified in  
%                                      modelSpec (optimal value if 
%                                      evalAllOptions is true).
%           cellArray: usedOptimizer - optimal value or used value, for each 
%                                      fold, for optimizer specified in 
%                                      modelSpec (optimal value if 
%                                      evalAllOptions is true).
%           cellArray: usedDistribution - optimal value or used value, for
%                                         each fold, for distribution
%                                         specified in modelSpec (optimal
%                                         value if evalAllOptions is true).
%           cellArray: usedLink - optimal value or used value, for each
%                                 fold, for link specified in modelSpec
%                                 (optimal value if evalAllOptions is
%                                 true).
%           int: seed - seed value used
%           table: dataTable - table used to train and test model after bad
%                              predictors have been removed.
%           array: targetData - dataTable with predictors scaled.
%                               Categorical variables are not scaled here
%                               (this is in contrast to other similar
%                               functions in this directory) becuase it is
%                               easier to allow matlab to handle the dummy
%                               encoding.
%           string: mdlType - options are fitlm, fitlme, and robustfit.  We
%                             do not include stepwise regression as it is
%                             considered to be too expensive.  If you would
%                             like to use stepwise regression you will need to
%                             build a seperate function.
%           string: mdlForm - gives the form of the model to create using
%                             wilkinson notation or a default string such
%                             as 'constant', 'interactions', etc.  For 
%                             example, y ~ x + 1 creates a model of x 
%                             with an intercept term using wilkinson
%                             notation
%           cell array: groupVars - gives predictors used to stratify folds
%           int: crossValFolds - gives the number of inner/outer cross
%                                validation folds
%           cell array: badPredNames - gives the names of predictors that
%                                      were removed from the table passed
%                                      to buildPoolDataMDL
%           function handle: scaleFunc - gives the function used to scale
%                                        audio predictions
%           int: scaleLower - gives the lower value of the scaling range
%                             created by scaleFunc.  default is 0.
%           int: scaleUpper - gives the upper value of the scaling range
%                             created by scaleFunc.  default is 1.
%   struct: mdlStruct
%       fields:
%           model: mdl# - gives the model found for each outer fold 
%           array: minimums -  gives the minimum value of each numerical
%                              predictor that was used for scalings.  If
%                              another method besides (# - min) / (max -
%                              min) is used, this value will indicate the
%                              name of the method.
%           array: maximums -  gives the maximum value of each numerical
%                              predictor that was used for scalings.  If
%                              another method besides (# - min) / (max -
%                              min) is used, this value will indicate the
%                              name of the method.
%   struct: errorStruct
%       fields:
%           array: outerPred# - gives the prediction for each sample using 
%                               mdl# on the testing fold
%           array: outerReal# - gives the real value for each sample of the
%                               testing fold. 
%           cellArray: outer#Inner#Iter# - gives the used/optimal index values
%                                          for the given outer and inner
%                                          fold for robust, 
%                                          covariancePattern, fitMethod,
%                                          optimizer, distribution, link,
%                                          and mean error per sample.  Has 
%                                          the form [robust,  
%                                          covariancePattern, fitMethod, 
%                                          optimizer, distribution, link,
%                                          meanError].
%                                                

function [ Settings, mdlStruct, errorStruct ] = buildMatlabPoolDataMDL( inputStruct, modelSpec )

    % handle inputStruct fields
    if isfield(inputStruct,'dirsToPath')
        temp = inputStruct.dirsToPath;
        for k = 1 : size(temp,2)
            addpath(genpath(temp{k})); 
        end
    end
    if isfield(inputStruct,'saveLocation')
        saveResults = true;
        saveLocation = inputStruct.saveLocation;
    else
        saveResults = false; 
    end
    if isfield(inputStruct,'response')
        response = inputStruct.response; 
    else
        error('You must provide the response you wish to predict');
    end
    if isfield(inputStruct,'dataLocation')
        load(inputStruct.dataLocation);
        temp = dataTable(:,end);
        temp = temp.Properties.VariableNames;
        if ~ismember(temp{1},response)
            error('The last column of the table that you pass to SVMFunc must be either sp, le, ld, ld2, lcl, ap, qol, im, or st'); 
        end
    else
        error('You must provided the location of the data you wish to use'); 
    end
    myCluster = parcluster('local');
    if isfield(inputStruct,'numCores')
        numCores = inputStruct.numCores;
        myCluster.NumWorkers = numCores;
        parpool(myCluster,numCores); 
    else
        myCluster.NumWorkers = 1;
        parpool(myCluster,1);
    end
    if isfield(inputStruct,'makePlot')
        makePlot = inputStruct.makePlot;
    else
        makePlot = true; 
    end
    if isfield(inputStruct,'groupVars')
        groupVars = inputStruct.groupVars;
    else
        error('You must provide the predictors used to stratify the folds') 
    end
    if isfield(inputStruct,'seed')
        seed = inputStruct.seed;
    else
        seed = 100; 
    end
    if isfield(inputStruct,'crossValFolds')
        crossValFolds = inputStruct.crossValFolds; 
    else
        crossValFolds = 5;
    end
    if isfield(inputStruct,'toRemoveCompletely')
        dataTable(:,inputStruct.toRemoveCompletely) = [];
    end
    if isfield(inputStruct,'toRemoveModel')
        toRemoveModel = inputStruct.toRemoveModel; 
    end
    if isfield(inputStruct,'scaleFunc')
        scaleFunc = inputStruct.scaleFunc;
    else
        error('You must provide a scaling function, even if it is not used due to no audio features being included');
    end
    if isfield(inputStruct,'scaleLower')
        scaleLower = inputStruct.scaleLower; 
    else
        scaleLower = 0;
    end
    if isfield(inputStruct,'scaleUpper')
        scaleUpper = inputStruct.scaleUpper; 
    else
        scaleUpper = 1;
    end
    if isfield(inputStruct,'catPreds')
        catPreds = inputStruct.catPreds;
    end
    
    % handle modelSpec fields
    if isfield(modelSpec,'mdlType')
        mdlType = modelSpec.mdlType;
    else
        error('You must provide the model type for this function to use'); 
    end
    if isfield(modelSpec, 'evalAllOptions')
        evalAllOptions = modelSpec.evalAllOptions;
    else
        evalAllOptions = true; 
    end
    if isfield(modelSpec, 'mdlForm')
        mdlForm = modelSpec.mdlForm;
    else
        error('You must provide the model type for the chosen model type for this function to use'); 
    end
    if isfield(modelSpec, 'robust')
        if evalAllOptions
            robust = {'off', 'andrews', 'bisquare', 'cauchy', 'fair', 'huber', 'logistic', 'ols', 'talwar', 'welsch'};
        else
            robust = modelSpec.robust;
        end
    else
        if evalAllOptions
            robust = {'off', 'andrews', 'bisquare', 'cauchy', 'fair', 'huber', 'logistic', 'ols', 'talwar', 'welsch'};
        else
            robust = {'off'};
        end
    end
    if isfield(modelSpec, 'covariancePattern')
        if evalAllOptions
            covariancePattern = {'FullCholesky', 'Full', 'Diagonal', 'Isotropic', 'CompSymm'};
        else
            covariancePattern = modelSpec.covariancePattern;
        end
    else
        if evalAllOptions
            covariancePattern = {'FullCholesky', 'Full', 'Diagonal', 'Isotropic', 'CompSymm'};
        else
            covariancePattern = {'FullCholesky'};
        end
    end
    if isfield(modelSpec, 'fitMethod')
        if evalAllOptions
            fitMethod = {'ML','REML'};
        else
            fitMethod = modelSpec.fitMethod;
        end
    else
        if evalAllOptions
           fitMethod = {'ML','REML'};
        else
           fitMethod = {'ML'};
        end
    end
    if isfield(modelSpec,'optimizer')
        if evalAllOptions
            optimizer = {'quasinewton','fminunc'};
        else
            optimizer = modelSpec.optimizer;
        end
    else
        if evalAllOptions
            optimizer = {'quasinewton','fminunc'};
        else
            optimizer = {'quasinewton'};
        end
    end
    if isfield(modelSpec, 'distribution')
        if evalAllOptions
            distribution = {'normal', 'poisson', 'gamma', 'inverse gaussian'};
        else
            distribution = modelSpec.distribution;
        end
    else
        if evalAllOptions
            distribution = {'normal', 'poisson', 'gamma', 'inverse gaussian'};
        else
            distribution = {'normal'};
        end
    end
    if isfield(modelSpec, 'link')
        if evalAllOptions
            link = {'identity', 'log', 'logit', 'probit', 'comploglog', 'reciprocal'};
        else
            link = modelSpec.link;
        end
    else
        if evalAllOptions
            link = {'identity', 'log', 'logit', 'probit', 'comploglog', 'reciprocal'};
        else
            link = {'normal'};
        end
    end
    
    disp(strcat('Building model(s) using',{' '},mdlType));
    disp(strcat('Model form:',{' '},mdlForm));
    disp(strcat('Outer/Inner cross validation folds:',{' '},num2str(crossValFolds)));
    if strcmp(mdlType,'fitlm')
        if evalAllOptions
            disp(strcat('Building model by optimizing for all',{' '},'options'));
        else
            disp(strcat('Robust:',{' '},robust));
        end
        
    elseif strcmp(mdlType,'fitlme')
        if evalAllOptions
            disp(strcat('Building model by optimizing for all',{' '},'options'));
        else
            disp(strcat('Covariance Pattern:',{' '},covariancePattern));
            disp(strcat('Fit Method:',{' '},fitMethod));
            disp(strcat('Optimizer:',{' '},optimizer));
        end
    elseif strcmp(mdlType,'fitglm')
        if evalAllOptions
            disp(strcat('Building model by optimizing for all',{' '},'options'));
        else
            disp(strcat('Distribution:',{' '},distribution));
            disp(strcat('Link:',{' '},link));
        end
    else
        error('Invalid mdlType.  mdlType must be either fitlm, fitlme, or fitglm.'); 
    end
    disp('Beginning Preprocessing');
    
    if exist('catPreds','var')
        temp = dataTable;
        if exist('toRemoveModel','var')
            temp(:,toRemoveModel) = [];
        end
        dummyData = temp(:,catPreds);
        for k = 1 : size(dummyData,2)
            dummyData.(catPreds{k}) = categorical(dummyData.(catPreds{k}));
        end
    end
    
    temp = dataTable;
    if exist('catPreds','var')
        if exist('toRemoveModel','var')
            temp(:,[catPreds,toRemoveModel,response]) = [];
        else
            temp(:,[catPreds,response]) = [];
        end
    else
        temp(:,response) = [];
    end
    varNames = temp.Properties.VariableNames;
    [ scaledData, minimums, maximums, badPreds ] = scaleFunc(table2array(temp),scaleLower,scaleUpper);
    badPredTable = dataTable(:,badPreds);
    badPredNames = badPredTable.Properties.VariableNames;
    
    if size(scaledData,2) == 0
        targetData = [dummyData,dataTable(:,response{1})];
    else
        scaledData = array2table(scaledData,'VariableNames',varNames);
        targetData = [dummyData,scaledData,dataTable(:,response{1})];
    end
    
    
    rng(seed);
    [ outerCV ] = stratifyByPreds( dataTable, groupVars, crossValFolds );
    
    disp('Working on outer folds');
    
    mdlStruct = struct;
    if size(minimums,2) == 0 && size(maximums,2) == 0
        mdlStruct.minimums = NaN;
        mdlStruct.maximums = NaN;
    else
        mdlStruct.minimums = minimums;
        mdlStruct.maximums = maximums;
    end
    errorStruct = struct;
    errorStruct.Key = {'Robust','CovariancePattern','FitMethod','Optimizer','Distribution','Link','MeanSampleError'};
    usedRobust = cell([1,crossValFolds]);
    usedRobust(:) = {NaN};
    usedCovariancePattern = cell([1,crossValFolds]);
    usedCovariancePattern(:) = {NaN};
    usedFitMethod = cell([1,crossValFolds]);
    usedFitMethod(:) = {NaN};
    usedOptimizer = cell([1,crossValFolds]);
    usedOptimizer(:) = {NaN};
    usedDistribution = cell([1,crossValFolds]);
    usedDistribution(:) = {NaN};
    usedLink = cell([1,crossValFolds]);
    usedLink(:) = {NaN};
    
    parfor outerFolds = 1 : crossValFolds
        disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Started'));
        trainingSet = targetData(training(outerCV,outerFolds),:);
        testingSet = targetData(test(outerCV,outerFolds),:);
        
        temp = dataTable(training(outerCV,outerFolds),:);
        [ innerCV ] = stratifyByPreds( temp, groupVars, crossValFolds );
        
        if strcmp(mdlType,'fitlm')
            % 10 for robust
            results = zeros(size(robust,2),crossValFolds);
        elseif strcmp(mdlType,'fitlme')
            % 5 for covPattern, 2 for fitMethod, 2 for optimizer
            results = zeros(size(covariancePattern,2),size(fitMethod,2),size(optimizer,2),crossValFolds);
        elseif strcmp(mdlType,'fitglm')
            % 4 for distribution, 6 for link
            results = zeros(size(distribution,2),size(link,2),crossValFolds);
        end
        for innerFolds = 1 : crossValFolds
            innerTraining = trainingSet(training(innerCV,innerFolds),:);
            innerTesting = trainingSet(test(innerCV,innerFolds),:);
            
            index = 1;
            outerTempStruct = struct;
            for robustLoop = 1 : size(robust,2)
                for covPatternLoop = 1 : size(covariancePattern,2)
                    for fitMethodLoop = 1 : size(fitMethod,2)
                        for optimizerLoop = 1 : size(optimizer,2)
                            for distLoop = 1 : size(distribution,2)
                                for linkLoop = 1 : size(link,2)
                                    if strcmp(mdlType,'fitlm')
                                        mdl = fitlm(innerTraining,mdlForm,'CategoricalVars',catPreds,'RobustOpts',robust{robustLoop});
                                    elseif strcmp(mdlType,'fitlme')
                                        mdl = fitlme(innerTraining,mdlForm,'CovariancePattern',covariancePattern{covPatternLoop},'FitMethod',fitMethod{fitMethodLoop},'Optimizer',optimizer{optimizerLoop});
                                    elseif strcmp(mdlType,'fitglm')
                                        mdl = fitglm(innerTraining,mdlForm,'CategoricalVars',catPreds,'Distribution',distribution{distLoop},'Link',link{linkLoop});
                                    end
                                    
                                    preds = predict(mdl,innerTesting(:,1:end-1));
                                    preds(preds < 0) = 0;
                                    preds(preds > 100) = 100;
                                    errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Iter',num2str(index));
                                    index = index + 1;
                                    innerTempStruct = struct;
                                    innerTempStruct.(errorResults) = [robustLoop,covPatternLoop,fitMethodLoop,optimizerLoop,distLoop,linkLoop,mean(abs(preds - table2array(innerTesting(:,end))))];
                                    outerTempStruct = catstruct(outerTempStruct,innerTempStruct);
                                    if strcmp(mdlType,'fitlm')
                                        % 10 for robust
                                        results(robustLoop,innerFolds) = mean(abs(preds - table2array(innerTesting(:,end))));
                                    elseif strcmp(mdlType,'fitlme')
                                        % 5 for covPattern, 2 for fitMethod, 2 for optimizer
                                        results(covPatternLoop,fitMethodLoop,optimizerLoop,innerFolds) = mean(abs(preds - table2array(innerTesting(:,end))));
                                    elseif strcmp(mdlType,'fitglm')
                                        % 4 for distribution, 6 for link
                                        results(distLoop,linkLoop,innerFolds) = mean(abs(preds - table2array(innerTesting(:,end))));
                                    end
                                end
                            end
                        end
                    end
                end
            end
            errorStruct = catstruct(errorStruct, outerTempStruct);
        end
        
        if strcmp(mdlType,'fitlm')
            % 10 for robust
            results = mean(results,2);
            [~,index] = min(results(:));
            [optRobust] = ind2sub(size(results),index);
            usedRobust{outerFolds} = robust{optRobust};
            mdl = fitlm(trainingSet,mdlForm,'CategoricalVars',catPreds,'RobustOpts',robust{optRobust});
        elseif strcmp(mdlType,'fitlme')
            % 5 for covPattern, 2 for fitMethod, 2 for optimizer
            results = mean(results,4);
            [~,index] = min(results(:));
            [optCovariancePattern, optFitMethod, optOptimizer] = ind2sub(size(results),index);
            usedCovariancePattern{outerFolds} = covariancePattern{optCovariancePattern};
            usedFitMethod{outerFolds} = fitMethod{optFitMethod};
            usedOptimizer{outerFolds} = optimizer{optOptimizer};
            mdl = fitlme(trainingSet,mdlForm,'CovariancePattern',covariancePattern{optCovariancePattern},'FitMethod',fitMethod{optFitMethod},'Optimizer',optimizer{optOptimizer});
        elseif strcmp(mdlType,'fitglm')
            % 4 for distribution, 6 for link
            results = mean(results,3);
            [~,index] = min(results(:));
            [optDistribution, optLink] = ind2sub(size(results),index);
            usedDistribution{outerFolds} = distribution{optDistribution};
            usedLink{outerFolds} = link{optLink};
            mdl = fitglm(trainingSet,mdlForm,'CategoricalVars',catPreds,'Distribution',distribution{optDistribution},'Link',link{optLink});
        end
        
        preds = predict(mdl,testingSet(:,1:end-1));
        preds(preds < 0) = 0;
        preds(preds > 100) = 100;
        mdlName = strcat('mdl',num2str(outerFolds));
        temp = struct;
        temp.(mdlName) = mdl;
        mdlStruct = catstruct(mdlStruct,temp);
        predName = strcat('outerPred',num2str(outerFolds));
        realName = strcat('outerReal',num2str(outerFolds));
        temp = struct;
        temp.(predName) = preds;
        temp.(realName) = table2array(testingSet(:,end));
        errorStruct = catstruct(errorStruct,temp);
        disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Completed'));
    end
    delete(gcp);
    
    if crossValFolds == 5 && makePlot
        hold on;
        h = cdfplot(abs(errorStruct.outerPred1 - errorStruct.outerReal1));
        set(h,'color','b');
        h = cdfplot(abs(errorStruct.outerPred2 - errorStruct.outerReal2));
        set(h,'color','r');
        h = cdfplot(abs(errorStruct.outerPred3 - errorStruct.outerReal3));
        set(h,'color','g');
        h = cdfplot(abs(errorStruct.outerPred4 - errorStruct.outerReal4));
        set(h,'color','c');
        h = cdfplot(abs(errorStruct.outerPred5 - errorStruct.outerReal5));
        set(h,'color','k');
        title(strcat('Cross Validation Results for',{' '},response{1}));
        xlabel('Abs Error');
        ylabel('Cumulative Percent');
        axis([0 100 0 1]);
        legend('Fold 1','Fold 2','Fold 3','Fold 4','Fold 5');
        hold off;
        if saveResults
            savefig(strcat(saveLocation,'.fig'));
        end
    end
    
    Settings = struct;
    Settings.usedRobust = usedRobust;
    Settings.usedCovariancePattern = usedCovariancePattern;
    Settings.usedFitMethod = usedFitMethod;
    Settings.usedOptimizer = usedOptimizer;
    Settings.usedDistribution = usedDistribution;
    Settings.usedLink = usedLink;
    Settings.seed = seed;
    Settings.dataTable = dataTable;
    Settings.targetData = targetData;
    Settings.mdlType = mdlType;
    Settings.modelForm = mdlForm;
    Settings.groupVars = groupVars;
    Settings.crossValFolds = crossValFolds;
    Settings.scaleFunc = scaleFunc;
    Settings.scaleLower = scaleLower;
    Settings.scaleUpper = scaleUpper;
    
    if size(badPredTable,2) > 0
        Settings.badPredNames = badPredNames;
    else
        Settings.badPredNames = NaN;
    end
    
    if saveResults
        save(saveLocation,'Settings','mdlStruct','errorStruct','-v7.3'); 
    end
    
end

