% Ryan Brummet 
% University of Iowa
%
% Notice that this function creates a model for each specified fold
% with a grid search being conducte over only gamma and cost.  Every field
% for the inputStruct has a default value except for dataLocation, 
% response, and groupVars.  Change values as needed.  Field names given to 
% inputStruct must be exactly named as presented below.  For this script to
% run the catstruct library is needed.  You may find the library at
% http://www.mathworks.com/matlabcentral/fileexchange/7842-catstruct.
% libSVM and libLinear are needed as well (the matlab implementations)
%
% NOTICE THAT THIS FUNCTION ASSUMES THAT THE ONLY CATEGORICAL VARIABLES
% THAT WILL EVER BE PASSED TO IT WILL BE MEMBERS OF THE SET.  CAUTION IS
% SUGGESTED WHEN PASSING NON AUDIOLOGY DATA TO THIS FUNCTION
%
% Params: 
%    struct: inputStruct
%       fields: 
%           string: libLocation - location of libSVM library
%           int: libToUse - 1 to use libSVM library syntax. 2 to use
%                           liblLinear library syntax.  Default is libSVM.
%           cell array: dirsToPath - location of directories to add to
%                                    path.  Add by column NOT row.
%           string: saveLocation - location to save results; if not present
%                                  results are only returned, not saved.
%                                  Include the full name you wish to use.
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
%           int: maxIterCount - gives the max "zoom ins" for grid search.
%                               default is 10
%           int: crossValFolds - gives the number of inner/outer cross
%                                validation folds. default is 5
%           array: startGammaValues - gives initial grid search range for
%                                     gamma.  Must be column array not row
%           array: startCostValues - gives initial grid search range for
%                                    cost.  Must be column array not row
%           bool: allowGridSearchEdgeVals - if true values at the edge of
%                                           the grid search, search range
%                                           are allowed (no error thrown).
%                                           Default is false
%           int: degree - gives degree of SVM model. default is 1
%           int: kernel - gives kernal/solver using either libSVM or
%                         libLinear syntax.  Default is 2 (RBF) for libSVM
%                         and 11 (L2-regularized L2-loss support vector 
%                         regression, primal) for libLinear.
%           cellArray: toRemove - cell array of predictor names to remove.
%                                 If a predictor is included here and is
%                                 categorical do not include it in catPreds
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
%                                  toRemove.
%           cell array: zeroPreds - gives the names of catPreds that have 0
%                                   as a category
%                                
% Return:
%   struct: SVMSettings
%       fields:
%           int: cost - optimal cost values for each fold
%           int: gamma - optimal gamma values for each fold
%           int: seed - seed value used
%           table: dataTable - table used to train and test model after bad
%                              predictors have been removed.
%           array: targetData - dummy encoded version of dataTable.  Each
%                               column corresponds to minimums and maximums
%                               fields of the mdlStruct struct returned
%           int: degree - degree used for SVM
%           int: kernal - SVM kernal using libSVM syntax
%           int: libToUse - lib used. 1 is libSVM. 2 is libLinear.
%           cell array: groupVars - gives predictors used to stratify folds
%           array: startGammaValues - gives initial grid search range for
%                                     gamma
%           array: startCostValues - gives initial grid search range for
%                                    cost
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
%           libSVM model: mdl# - gives the model found for each outer fold 
%           array: minimums - gives the minimum value of each numerical
%                              predictor that was used for scalings.  If
%                              another method besides (# - min) / (max -
%                              min) is used, this value will indicate the
%                              name of the method.
%           array: maximums - gives the maximum value of each numerical
%                              predictor that was used for scalings.  If
%                              another method besides (# - min) / (max -
%                              min) is used, this value will indicate the
%                              name of the method.
%   struct: errorStruct
%       fields:
%           array: outerPred# - gives the prediction for each sample using mdl#
%                          on the testing fold
%           array: outerReal# - gives the real value for each sample of the
%                          testing fold. 
%           array: outer#Inner#Depth#Gamma#Cost# - gives the actual gamma
%                                                  and cost values used to
%                                                  produce the mean
%                                                  abs error of the current
%                                                  outer/inner fold combo.
%                                                  Has format [gamma, cost,
%                                                  meanError]
%                                                

function [ SVMSettings, mdlStruct, errorStruct ] = buildPoolDataMDL( inputStruct )

    % handle present and missing field values
    if isfield(inputStruct,'libLocation')
        addpath(genpath(inputStruct.libLocation));
    end
    if isfield(inputStruct,'libToUse')
        libToUse = inputStruct.libToUse;
    else
        libToUse = 1;
    end
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
    if isfield(inputStruct,'maxIterCount')
        maxIterCount = inputStruct.maxIterCount; 
    else
        maxIterCount = 10;
    end
    if isfield(inputStruct,'crossValFolds')
        crossValFolds = inputStruct.crossValFolds; 
    else
        crossValFolds = 5;
    end
    if isfield(inputStruct,'startGammaValues')
        if libToUse == 2
            startGammaValues = [1]; 
        else
            startGammaValues = inputStruct.startGammaValues;
        end
    else
        if libToUse == 2
            startGammaValues = [1];
        else
            startGammaValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000];
        end
    end
    if isfield(inputStruct,'startCostValues')
        startCostValues = inputStruct.startCostValues; 
    else
        startCostValues = [.00001,.0001,.001,.01,.1,1,10,100,1000,10000,50000,100000];
    end
    if isfield(inputStruct,'allowGridSearchEdgeVals')
        allowGridSearchEdgeVals = inputStruct.allowGridSearchEdgeVals;
    else
        allowGridSearchEdgeVals = false;
    end
    if isfield(inputStruct,'degree')
        degree = inputStruct.degree; 
    else
        degree = 1;
    end
    if isfield(inputStruct,'kernel')
        kernel = inputStruct.kernel;
    else
        if libToUse == 1
            kernel = 2;
        elseif libToUse == 2
            kernel = 11;
        end
    end
    if isfield(inputStruct,'toRemove')
        dataTable(:,inputStruct.toRemove) = [];
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
        scaleUpper = inputStruct.scaleUpper;
    end
    if isfield(inputStruct,'catPreds')
        catPreds = inputStruct.catPreds;
    end
    if isfield(inputStruct,'zeroPreds')
        zeroPreds = inputStruct.zeroPreds;
    else
        zeroPreds = ''; 
    end
    
    % get information used to find optimal place for parallelization
    innerParFor = ((ceil(size(startGammaValues,2) / numCores) * size(startCostValues,2)) + (ceil(5 / numCores) * 5 * (maxIterCount - 1))) * (crossValFolds * crossValFolds);
    outerParFor = ((size(startGammaValues,2) * size(startCostValues,2)) + (5 * 5 * (maxIterCount - 1))) * (ceil(crossValFolds / numCores) * crossValFolds);
    
    disp(strcat('Optimal SVM grid params will now be found for:',{' '},response));
    disp(strcat('Max grid search iterations:',{' '},num2str(maxIterCount)));
    disp(strcat('Outer/Inner cross validation folds:',{' '},num2str(crossValFolds)));
    disp(strcat('Degree:',{' '},num2str(degree)));
    disp(strcat('Kernel:',{' '},num2str(kernel)));
    if outerParFor <= innerParFor
        disp({'Using outer parallelization'}); 
    else
        disp({'Using inner parallelization'});
    end
    disp('Beginning Preprocessing');
    
    if exist('catPreds','var')
        dummyData = dummyEncode( dataTable(:,catPreds), catPreds, zeroPreds );
    end
    
    temp = dataTable;
    if exist('catPreds','var')
        temp(:,[catPreds,response]) = [];
    else
        temp(:,response) = [];
    end
    [ scaledData, minimums, maximums, badPreds ] = scaleFunc(table2array(temp),scaleLower,scaleUpper);
    temp = dataTable(:,badPreds);
    badPredNames = temp.Properties.VariableNames;
    
    targetData = [dummyData,scaledData,dataTable.(response{1})];
    
    rng(seed);
    [ outerCV ] = stratifyByPreds( dataTable, groupVars, crossValFolds );
    
    disp('Finding Opt Params for outer folds');
    
    gamma = zeros(1,crossValFolds);
    cost = zeros(1,crossValFolds);
    
    mdlStruct = struct;
    mdlStruct.minimums = minimums;
    mdlStruct.maximums = maximums;
    errorStruct = struct;
    
    if outerParFor <= innerParFor
        parfor outerFolds = 1 : crossValFolds
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Started'));
            trainingSet = targetData(training(outerCV,outerFolds),:);
            testingSet = targetData(test(outerCV,outerFolds),:);

            gammaValues = startGammaValues;
            costValues = startCostValues;
            temp = dataTable(training(outerCV,outerFolds),:);
            [ innerCV ] = stratifyByPreds( temp, groupVars, crossValFolds );
            
            % find opt params for current outer fold using cross validation
            optParam = true;
            preOptC = NaN;
            preOptG = NaN;
            iterationCount = 0;
            while optParam && iterationCount < maxIterCount
                iterationCount = iterationCount + 1;
                results = zeros(size(gammaValues,2),size(costValues,2),crossValFolds);
                for innerFolds = 1 : crossValFolds
                    innerTraining = trainingSet(training(innerCV,innerFolds),:);
                    innerTesting = trainingSet(test(innerCV,innerFolds),:);
                    
                    %Grid Search
                    [p,q] = meshgrid(gammaValues, costValues);
                    pairs = [p(:) q(:)];
                    tempResults = zeros(size(pairs,1),1);
                    outerTempStruct = struct;
                    for p = 1 : size(pairs,1)
                        if libToUse == 1
                            settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(pairs(p,1),'%f'),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mdl = svmtrain(innerTraining(:,end),innerTraining(:,1:end-1),settings{1});
                            preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
                        else
                            settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mySparseTrain = sparse(innerTraining(:,1:end-1));
                            mdl = train(innerTraining(:,end),mySparseTrain,settings{1});
                            mySparseTest = sparse(innerTesting(:,1:end-1));
                            preds = predict(innerTesting(:,end),mySparseTest,mdl);
                        end
                        
                        preds(preds < 0) = 0;
                        preds(preds > 100) = 100;
                        errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Error',num2str(p));
                        innerTempStruct = struct;
                        innerTempStruct.(errorResults) = mean(abs(preds - innerTesting(:,end)));
                        tempResults(p) = innerTempStruct.(errorResults)
                        outerTempStruct = catstruct(outerTempStruct,innerTempStruct);
                    end
                    for g = 1 : size(gammaValues,2)
                        results(g,1:size(costValues,2),innerFolds) = tempResults(1 + ((g - 1) * size(costValues,2)):g * size(costValues,2));
                        for c = 1 : size(costValues,2)
                            errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Error',num2str(((g - 1) * size(costValues,2)) + c));
                            tempError = outerTempStruct.(errorResults);
                            outerTempStruct = rmfield(outerTempStruct,errorResults);
                            errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c));
                            outerTempStruct.(errorResults) = [gammaValues(g),costValues(c),tempError];
                        end
                    end
                    errorStruct = catstruct(errorStruct, outerTempStruct);
                end
                results = mean(results,3);
                [temp,index] = min(results(:));
                [optG,optC] = ind2sub(size(results),index);
                if ((optC == 1 || optC == size(costValues,2)) && size(costValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optC = costValues(optC);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optC = preOptC;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optC = costValues(optC);
                        optParam = false;
                    else
                        preOptC = costValues(optC);
                        if size(costValues,2) == 1
                            costValues = costValues;
                        elseif size(costValues,2) == 2
                            costValues = [costValues(1), costValues(1) + (costValues(2) - costValues(1)) / 2, costValues(2)];
                            costValues = [costValues(1), costValues(1) + ((costValues(2) - costValues(1)) / 2), costValues(2), costValues(2) + ((costValues(3) - costValues(2)) / 2), costValues(3)];
                        else
                            costValues = [costValues(optC - 1), costValues(optC - 1) + ((costValues(optC) - costValues(optC - 1)) / 2), costValues(optC), costValues(optC) + ((costValues(optC + 1) - costValues(optC)) / 2), costValues(optC + 1)];
                        end
                        optC = costValues(optC);
                    end
                end
                
                if  ((optG == 1  || optG == size(gammaValues,2)) && size(gammaValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optG = preOptG;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        preOptG = gammaValues(optG);
                        if size(gammaValues,2) == 1
                            gammaValues = gammaValues;
                        elseif size(gammaValues,2) == 2
                            gammaValues = [gammaValues(1), gammaValues(1) + (gammaValues(2) - gammaValues(1)) / 2, gammaValues(2)];
                            gammaValues = [gammaValues(1), gammaValues(1) + ((gammaValues(2) - gammaValues(1)) / 2), gammaValues(2), gammaValues(2) + ((gammaValues(3) - gammaValues(2)) / 2), gammaValues(3)];
                        else
                            gammaValues = [gammaValues(optG - 1), gammaValues(optG - 1) + ((gammaValues(optG) - gammaValues(optG - 1)) / 2), gammaValues(optG), gammaValues(optG) + ((gammaValues(optG + 1) - gammaValues(optG)) / 2), gammaValues(optG + 1)];
                        end
                        optG = gammaValues(optG);
                    end
                end
            end
            gamma(outerFolds) = optG;
            cost(outerFolds) = optC;
            if libToUse == 1
                settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(optG,'%f'),{' -c'},{' '},num2str(optC,'%f')); 
                mdl = svmtrain(trainingSet(:,end),trainingSet(:,1:end-1),settings{1});
                preds = svmpredict(testingSet(:,end),testingSet(:,1:end-1),mdl);
            else
                settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(optC,'%f'));
                mySparseTrain = sparse(trainingSet(:,1:end-1));
                mdl = train(trainingSet(:,end),mySparseTrain,settings{1});
                mySparseTest = sparse(testingSet(:,1:end-1));
                preds = predict(testingSet(:,end),mySparseTest,mdl);
            end
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
            temp.(realName) = testingSet(:,end);
            errorStruct = catstruct(errorStruct,temp);
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Completed'));
        end
    else
        for outerFolds = 1 : crossValFolds
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Started'));
            trainingSet = targetData(training(outerCV,outerFolds),:);
            testingSet = targetData(test(outerCV,outerFolds),:);

            gammaValues = startGammaValues;
            costValues = startCostValues;
            temp = dataTable(training(outerCV,outerFolds),:);
            [ innerCV ] = stratifyByPreds( temp, groupVars, crossValFolds );
            
            % find opt params for current outer fold using cross validation
            optParam = true;
            preOptC = NaN;
            preOptG = NaN;
            iterationCount = 0;
            while optParam && iterationCount < maxIterCount
                iterationCount = iterationCount + 1;
                results = zeros(size(gammaValues,2),size(costValues,2),crossValFolds);
                for innerFolds = 1 : crossValFolds
                    innerTraining = trainingSet(training(innerCV,innerFolds),:);
                    innerTesting = trainingSet(test(innerCV,innerFolds),:);
                    
                    %Grid Search
                    [p,q] = meshgrid(gammaValues, costValues);
                    pairs = [p(:) q(:)];
                    tempResults = zeros(size(pairs,1),1);
                    outerTempStruct = struct;
                    parfor p = 1 : size(pairs,1)
                        if libToUse == 1
                            settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(pairs(p,1),'%f'),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mdl = svmtrain(innerTraining(:,end),innerTraining(:,1:end-1),settings{1});
                            preds = svmpredict(innerTesting(:,end),innerTesting(:,1:end-1),mdl);
                        else
                            settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(pairs(p,2),'%f'));
                            mySparseTrain = sparse(innerTraining(:,1:end-1));
                            mdl = train(innerTraining(:,end),mySparseTrain,settings{1});
                            mySparseTest = sparse(innerTesting(:,1:end-1));
                            preds = predict(innerTesting(:,end),mySparseTest,mdl);
                        end
                        
                        preds(preds < 0) = 0;
                        preds(preds > 100) = 100;
                        errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Error',num2str(p));
                        innerTempStruct = struct;
                        innerTempStruct.(errorResults) = mean(abs(preds - innerTesting(:,end)));
                        tempResults(p) = innerTempStruct.(errorResults);
                        outerTempStruct = catstruct(outerTempStruct,innerTempStruct);
                    end
                    for g = 1 : size(gammaValues,2)
                        results(g,1:size(costValues,2),innerFolds) = tempResults(1 + ((g - 1) * size(costValues,2)):g * size(costValues,2));
                        for c = 1 : size(costValues,2)
                            errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Error',num2str(((g - 1) * size(costValues,2)) + c));
                            tempError = outerTempStruct.(errorResults);
                            outerTempStruct = rmfield(outerTempStruct,errorResults);
                            errorResults = strcat('outer',num2str(outerFolds),'Inner',num2str(innerFolds),'Depth',num2str(iterationCount),'Gamma',num2str(g),'Cost',num2str(c));
                            outerTempStruct.(errorResults) = [gammaValues(g),costValues(c),tempError];
                        end
                    end
                    errorStruct = catstruct(errorStruct, outerTempStruct);
                end
                results = mean(results,3);
                [temp,index] = min(results(:));
                [optG,optC] = ind2sub(size(results),index);
                if ((optC == 1 || optC == size(costValues,2)) && size(costValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optC = costValues(optC);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optC = preOptC;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optC = costValues(optC);
                        optParam = false;
                    else
                        preOptC = costValues(optC);
                        if size(costValues,2) == 1
                            costValues = costValues;
                        elseif size(costValues,2) == 2
                            costValues = [costValues(1), costValues(1) + (costValues(2) - costValues(1)) / 2, costValues(2)];
                            costValues = [costValues(1), costValues(1) + ((costValues(2) - costValues(1)) / 2), costValues(2), costValues(2) + ((costValues(3) - costValues(2)) / 2), costValues(3)];
                        else
                            costValues = [costValues(optC - 1), costValues(optC - 1) + ((costValues(optC) - costValues(optC - 1)) / 2), costValues(optC), costValues(optC) + ((costValues(optC + 1) - costValues(optC)) / 2), costValues(optC + 1)];
                        end
                        optC = costValues(optC);
                    end
                end
                
                if  ((optG == 1  || optG == size(gammaValues,2)) && size(gammaValues,2) > 2)
                    if allowGridSearchEdgeVals
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        if isnan(preOptC) && isnan(preOptG)
                            error('Initial range for startCost and startGammaValues is too small');
                        elseif isnan(preOptC)
                            error('Initial range for startCost is too small');
                        elseif isnan(preOptG)
                            error('Initial range for startGammaValues is too small');
                        else
                            optG = preOptG;
                            optParam = false;
                        end
                    end
                else
                    if iterationCount == maxIterCount
                        optG = gammaValues(optG);
                        optParam = false;
                    else
                        preOptG = gammaValues(optG);
                        if size(gammaValues,2) == 1
                            gammaValues = gammaValues;
                        elseif size(gammaValues,2) == 2
                            gammaValues = [gammaValues(1), gammaValues(1) + (gammaValues(2) - gammaValues(1)) / 2, gammaValues(2)];
                            gammaValues = [gammaValues(1), gammaValues(1) + ((gammaValues(2) - gammaValues(1)) / 2), gammaValues(2), gammaValues(2) + ((gammaValues(3) - gammaValues(2)) / 2), gammaValues(3)];
                        else
                            gammaValues = [gammaValues(optG - 1), gammaValues(optG - 1) + ((gammaValues(optG) - gammaValues(optG - 1)) / 2), gammaValues(optG), gammaValues(optG) + ((gammaValues(optG + 1) - gammaValues(optG)) / 2), gammaValues(optG + 1)];
                        end
                        optG = gammaValues(optG);
                    end
                end
            end
            gamma(outerFolds) = optG;
            cost(outerFolds) = optC;
            if libToUse == 1
                settings = strcat('-q -s 3 -t',{' '},num2str(kernel),{' -d'},{' '},num2str(degree),{' -g'},{' '},num2str(optG,'%f'),{' -c'},{' '},num2str(optC,'%f')); 
                mdl = svmtrain(trainingSet(:,end),trainingSet(:,1:end-1),settings{1});
                preds = svmpredict(testingSet(:,end),testingSet(:,1:end-1),mdl);
            else
                settings = strcat('-q -s',{' '},num2str(kernel),{' -c'},{' '},num2str(optC,'%f'));
                mySparseTrain = sparse(trainingSet(:,1:end-1));
                mdl = train(trainingSet(:,end),mySparseTrain,settings{1});
                mySparseTest = sparse(testingSet(:,1:end-1));
                preds = predict(testingSet(:,end),mySparseTest,mdl);
            end
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
            temp.(realName) = testingSet(:,end);
            errorStruct = catstruct(errorStruct,temp);
            disp(strcat('Outer Fold',{' '},num2str(outerFolds),{' '},'Completed'));
        end
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
    
    SVMSettings = struct;
    SVMSettings.cost = cost;
    SVMSettings.gamma = gamma;
    SVMSettings.maxIterCount = maxIterCount;
    SVMSettings.seed = seed;
    SVMSettings.dataTable = dataTable;
    SVMSettings.targetData = targetData;
    SVMSettings.degree = degree;
    SVMSettings.kernal = kernel;
    SVMSettings.libToUse = libToUse;
    SVMSettings.groupVars = groupVars;
    SVMSettings.startGammaValues = startGammaValues;
    SVMSettings.startCostValues = startCostValues;
    SVMSettings.crossValFolds = crossValFolds;
    SVMSettings.scaleFunc = scaleFunc;
    SVMSettings.scaleLower = scaleLower;
    SVMSettings.scaleUpper = scaleUpper;
    
    if exist('badPredTable','var')
        SVMSettings.badPredNames = badPredNames;
    else
        SVMSettings.badPredNames = NaN;
    end
    
    if saveResults
        save(saveLocation,'SVMSettings','mdlStruct','errorStruct','-v7.3'); 
    end
    
end

