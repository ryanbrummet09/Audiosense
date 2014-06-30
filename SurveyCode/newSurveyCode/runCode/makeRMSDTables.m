%Ryan Brummet
%University of Iowa

%% initialize
clearvars;
close all;
warning('off', 'all');

dataFileName = 'DataTable.mat';  %must be .mat file, variable must be 'unProcessedData'
makeGraphs = true;
saveVariables = true; %if true, saves variables.  if make graphs also true, saves variables with graphs
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;   %a user not having this # of samples has all samples removed
minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]

outerCrossValFolds = 5;
innerCrossValFolds = 5;
error_fn = @(predicted,real,numSamples) sqrt(sum((real - predicted).^2,1)/numSamples);
robustFit = true; %if false, poly fit is used to find best mapping per 
                   %mapping pair for deg = 1:maxDeg. if true, robustfit is 
                   %used to find the best mapping per mapping pair.
maxDeg = 5;
groupVars = {'ac', 'lc', 'nz', 'patient'};  %used to build a composite variable that is used to statify in cross validation
randomizeDataSampleOrder = true;
bestMapPickMethod = 1;  %1 pick the mapping with the least error out of the all folds
                        %2 pick the mapping with the median error
                        %3 pick the mapping with the most error
savePathWtName = {'/Users/ryanbrummet/Documents/MATLAB/Audiology/robustMappingGraphs'};  %can be robustMappingGraphs, polyMappingGraphs, robustMappingGraphsWtOut_________(list attr), or polyMappingGraphsWtOut______(list attr)

%% global variables
attributes = {'sp', 'le', 'ld', 'ld2', 'lcl', 'ap','qol','im', 'st'};
contexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
miscDataInfo = {'patient', 'listening', 'userinitiated', 'hau',};
extractedColNames = [miscDataInfo contexts attributes];
normValues = {'Not Normalized','Globally Normalized','User Normalized'};
normValues2 = {'notNormalized','globallyNormalized','userNormalized'};
tableColumns = {'TARGET';'SP';'LE';'LD';'LD2';'LCL';'AP'; 'QOL'; 'IM'; 'ST';'MEAN';'STD'};
tableRows = {'Fold 1';'Fold 2';'Fold 3';'Fold 4';'Fold 5'; ...
    'Avg';'Max';'Min'};
mapStyle = {'Poly';'Robust'};
bestMapPick = {'least error', 'median error', 'most error'};

%% preprocess data and make directories
load(dataFileName);

%remove samples where user is listening
if omitListening
    unProcessedData = unProcessedData(~strcmp(unProcessedData.listening,'true'),:);
end

%remove samples where user isn't listening
if omitNotListening
    unProcessedData = unProcessedData(~strcmp(unProcessedData.listening,'false'),:);
end

%remove samples where user initiated survey
if omitUserInit
    unProcessedData = unProcessedData(~strcmp(unProcessedData.userinitiated,'true'),:);
end

%remove samples where user didn't initiate survey
if omitNotUserInit
    unProcessedData = unProcessedData(~strcmp(unProcessedData.userinitiated,'false'),:);
end

%remove samples where user is wearing hearing aid
if omitWearingHearingAid
    unProcessedData = unProcessedData(~strcmp(unProcessedData.hau,'true'),:);
end

%remove samples where user isn't wearing hearing aid
if omitNotWearingHearingAid
    unProcessedData = unProcessedData(~strcmp(unProcessedData.hau,'false'),:);
end

%remove samples that don't make duration requirements and add unix
%timestamp to table
[unProcessedData] = findSamplesMeetingDurationReq(unProcessedData,minPercentOfDurationFromMean);

%remove fifty values
if removeFifties
    fiftyCorrectionDate = getUnixTime(2014,1,30,0,0,0);
    for k = 1 : size(attributes,2)
         unProcessedData.(attributes{k})((unProcessedData.(attributes{k}) == 50) ...
             & unProcessedData.timestamp < fiftyCorrectionDate) = NaN;
    end
end

%remove samples where all attributes are NaN
toBeRemoved = zeros(size(unProcessedData,1),1);
for k = 1 : size(attributes,2)
    toBeRemoved = isnan(unProcessedData.(attributes{k})) + toBeRemoved;
end
unProcessedData = unProcessedData(toBeRemoved < size(attributes,2),:);

%remove samples with users with an insufficient number of samples
[unProcessedData] = removeNonQualUsers(unProcessedData,minNumSamplesPerUser);

%randomize the row order of the matrix
if randomizeDataSampleOrder
    unProcessedData = unProcessedData(randperm(size(unProcessedData,1)),:);
end

%extract relevant columns
processedData = unProcessedData(:,extractedColNames);

%re-assign duplicate condition values
conditionVals = processedData.condition;
for k = 1 : size(conditionVals,1)
    if conditionVals(k,1) == 6
        conditionVals(k,1) = 5;
    elseif conditionVals(k,1) == 21
        conditionVals(k,1) = 1;
    elseif conditionVals(k,1) == 22
        conditionVals(k,1) = 2;
    elseif conditionVals(k,1) == 23
        conditionVals(k,1) = 3;
    elseif conditionVals(k,1) == 24
        conditionVals(k,1) = 4;
    end
end
processedData.condition = conditionVals;

%make directories
mkdir(char(savePathWtName));
for mkDirNorm = 1 : 3
    mkdir(char(strcat(savePathWtName,{'/'},normValues2{mkDirNorm})));
    for folds = 1 : outerCrossValFolds
        mkdir(char(strcat(savePathWtName,{'/'},normValues2{mkDirNorm},{'/Fold'},num2str(folds))));
    end
end

%clear variables that are no longer needed
clearvars fiftyCorrectionDate unProcessedData mkDirNorm folds toBeRemoved conditionVals;


%% Determine the best polynomials for each individual mapping by using cross validation

%first create cvVar, a combined variable consisting of several context
%variables.  This is used to give a even distribution of contexts per fold
cvVar = zeros(size(processedData,1),1);
for gv = 1 : size(groupVars,2)
    if strcmp(char(groupVars{gv}),'patient')
        cvVar = cvVar + processedData.patient;
    else
        cvVar = cvVar + processedData.(groupVars{gv}) * 10 ^ (-gv);
    end
end
processedData.cvVar = cvVar;

%look at the effects of each normalization technique
%norm = 1 is no norm, norm = 2 is global norm, norm = 3 is user norm
for norm = 1 : 3
    %clearvars that are being recycled and close any open figures
    clearvars outerCV iteration normAVG normSTD foldData plotVals;
    close all;
    
    %this value is used to associate mean and std values with proper
    %partitions
    iteration = 0;
    
    %create paritions of the whole data set
    outerCV = cvpartition(processedData.cvVar,'kfold',outerCrossValFolds);
    
    %iterate through all outer paritions, rotating which partition is the
    %validation set
    for outerFolds = 1 : outerCrossValFolds
        %clearvars that are being recycled
        clearvars innerCV allInnerResults outerTrainingSet validationSet bestResults;
        
        %create table to hold best results
        bestResults = table;
        
        %define outer training and validation sets
        outerTrainingSet = processedData(training(outerCV,outerFolds),:);
        validationSet = processedData(test(outerCV,outerFolds),:);
        
        %create partition of the outer partitions being used for the
        %training set
        innerCV = cvpartition(outerTrainingSet.cvVar,'kfold',innerCrossValFolds);
        
        %create variable that hold all results generated from this
        %particular outer training set
        allInnerResults = table;
        
        %iterate through all groups created out of outer group training set
        %rotating which of the inner groups is the testing set
        for innerFolds = 1 : innerCrossValFolds
            %clear vars that are being recycled
            clearvars innerResults normData;
            
            %create variable that holds normalized outer training data.
            %that is this variable holds normalized data excluding the
            %validation set
            normData = table;
            
            %normalize the training and testing sets using values that are
            %calculated from the training set.  Here training set refers to
            %the set of values within the set of outer data that is not the
            %validation set and does not include the testing set
            iteration = iteration + 1;
            if norm ~= 1
                [ temp, AVG, STD ] = normalizeDataAndFindNormVals( processedData, ...
                    outerTrainingSet, attributes, innerCV, innerFolds, norm );
                normData = temp(training(outerCV,outerFolds),:);
                normAVG(:,:,iteration) = AVG;
                normSTD(:,:,iteration) = STD;
            else
                normData = outerTrainingSet;
            end
            
            %define the inner trainining set and the testing set
            innerTrainingSet = normData(training(innerCV,innerFolds),:);
            testingSet = normData(test(innerCV,innerFolds),:);
            
            %find spearman's rank coefficients if makeGraphs is true and
            %iteration is zero
            if makeGraphs == true && iteration == 1
                for targetAttr = 1 : size(attributes,2)
                    for mapAttr = 1 : size(attributes,2)
                        if targetAttr ~= mapAttr
                            %for each attribute pair, ww only consider
                            %samples where each attribute is not NaN from
                            %the current training set
                            trainingIndexes = ~isnan(innerTrainingSet.(attributes{targetAttr}) ...
                                + innerTrainingSet.(attributes{mapAttr}));
                          
                            %find averages
                            targetAttrAvg = mean(innerTrainingSet(trainingIndexes,:).(attributes{targetAttr}));
                            mapAttrAvg = mean(innerTrainingSet(trainingIndexes,:).(attributes{mapAttr}));
                            
                            %find spearmans coeficient
                            spearmanVal(targetAttr,mapAttr) = sum((innerTrainingSet(trainingIndexes,:).(attributes{targetAttr}) - targetAttrAvg) .* ...
                                (innerTrainingSet(trainingIndexes,:).(attributes{mapAttr}) - mapAttrAvg)) / ...
                                sqrt(sum(((innerTrainingSet(trainingIndexes,:).(attributes{targetAttr}) - targetAttrAvg).^2)) * ...
                                sum(((innerTrainingSet(trainingIndexes,:).(attributes{mapAttr}) - mapAttrAvg).^2)));
                        else
                            spearmanVal(targetAttr,mapAttr) = 1; 
                        end
                    end
                end
                
                %make spearman coef table
                f = figure(1);
                uitable(f,'Data', spearmanVal, 'RowName',attributes, 'ColumnName',attributes, 'Position', [395 295 720 176]);
                
                %save fig
                savefig(gcf,char(strcat(savePathWtName,{'/'},normValues2{norm},{'/'},'spearmanCorrelation')));
            end
            
            %create variable to hold all mappings for all deg for this
            %particular inner fold
            innerResults = table;
            
            %test every possible poly mapping from deg = 0 to degMax and
            %store results in the table innerResults which is of the form
            %iteration, targetAttr, mapAttr, percentGoodSamplesTrainedOn,
            %optimalTrainingPercent, percentGoodSamplesTestedOn, 
            %optimalTestingPercent, percentGoodSamplesInValSet, 
            %optimalValPercent, deg, mapCoef, error.  Notice that mapCoef 
            %consists of deg + 1 columns in the table. Also notice that a 
            %deg of -1 indicates that robust fit was used.  Robust fit uses
            %a linear mapping.
            for targetAttr = 1 : size(attributes,2)
                for mapAttr = 1 : size(attributes,2)
                    %clear vars that are being recycled
                    clearvars tempTable;
                    
                    %create table with one row to hold each map pair for
                    %this fold
                    tempTable = table;
                    tempTable.iteration = iteration;
                    
                    %find indexes of samples with the given map pair where
                    %neither value is NaN for the training and testing sets
                    trainingIndexes = ~isnan(innerTrainingSet.(attributes{targetAttr}) ...
                        + innerTrainingSet.(attributes{mapAttr}));
                    testingIndexes = ~isnan(testingSet.(attributes{targetAttr}) ...
                        + testingSet.(attributes{mapAttr}));
                    
                    %find the number of samples with the given map pair
                    %where neither value is NaN in the validation set
                    numGoodSamplesInValSet = sum(~isnan(validationSet.(attributes{targetAttr}) ...
                        + validationSet.(attributes{mapAttr})));
                    
                    %find the total number of samples with the given map
                    %pair in the entire data set where neither value is NaN
                    numTotalGoodSamples = (sum(trainingIndexes) + sum(testingIndexes) + numGoodSamplesInValSet);
                    
                    %assign misc table column variables for this row
                    tempTable.targetAttr = targetAttr;
                    tempTable.mapAttr = mapAttr;
                    tempTable.percentGoodSamplesTrainedOn = sum(trainingIndexes) / numTotalGoodSamples;
                    tempTable.optimalTrainingPercent = ((outerCrossValFolds - 1) / outerCrossValFolds) ...
                        * ((innerCrossValFolds - 1) / innerCrossValFolds);
                    tempTable.percentGoodSamplesTestedOn = sum(testingIndexes) / numTotalGoodSamples;
                    tempTable.optimalTestingPercent = ((outerCrossValFolds - 1) / outerCrossValFolds) * (1 / innerCrossValFolds);
                    tempTable.percentGoodSamplesInValSet = numGoodSamplesInValSet / numTotalGoodSamples;
                    tempTable.optimalValPercent = 1 / outerCrossValFolds;
                    
                    %if targetAttr == mapAttr we don't need to find the
                    %best mapping or its error since we already know what
                    %each is.  Otherwise we must determine what the best
                    %mapping is (including the degree if not using robust
                    %mapping) and its error.
                    if targetAttr == mapAttr
                        tempTable.deg = 1;
                        mapCoef = zeros(1,maxDeg);
                        mapCoef(1,maxDeg - 1) = 1;
                        tempTable.mapCoef = mapCoef;
                        tempTable.error = 0;
                    else
                        %we use two different mappings depending on
                        %robustFIT.  If robustFIT is true we use robustFIT
                        %otherwise we use polynomial fitting.  If we use
                        %polynomial fitting we investigate all polynomials
                        %with deg = 0 to deg = maxDeg.
                        if robustFit
                            
                            %map using robust mapping
                            tempTable.deg = -1;
                            mapCoef = zeros(1,maxDeg + 1);
                            mapCoef(1,maxDeg:maxDeg + 1) = ...
                                robustfit(innerTrainingSet(trainingIndexes,:).(attributes{mapAttr}), ...
                                innerTrainingSet(trainingIndexes,:).(attributes{targetAttr}));
                            
                            %reorder the output from matlab's robust
                            %mapping function to fit the output from its
                            %polymapping funciton.  In particular,
                            %coefficients in decreasing order of degree
                            mapCoef(find(mapCoef~=0,1):end) = fliplr(mapCoef(find(mapCoef~=0,1):end));
                            tempTable.mapCoef = mapCoef;
                            
                            %determine error.  Values greater than or less
                            %than possible values are mapped to the nearest
                            %real value.  This improves accuracy.
                            tempTable.error = feval(error_fn, ...
                                evaluatePolynomial(mapCoef,testingSet(testingIndexes,:).(attributes{mapAttr})),...
                                testingSet(testingIndexes,:).(attributes{targetAttr}),size(testingIndexes,1));
                            
                            %add tempTable to innerResults
                            innerResults = [innerResults ; tempTable];
                            
                        else
                            %here we are using polyfit instead of robust
                            %fit.  Since there are multiple deg
                            %possibilities for polyfit we explore all deg
                            %on the interval [0,maxDeg]
                            for deg = 0 : maxDeg
                                
                                %map using polyfit and deg
                                tempTable.deg = deg;
                                mapCoef = zeros(1,maxDeg + 1);
                                mapCoef(1,maxDeg - deg + 1:maxDeg + 1) = ...
                                    polyfit(innerTrainingSet(trainingIndexes,:).(attributes{mapAttr}), ...
                                    innerTrainingSet(trainingIndexes,:).(attributes{targetAttr}),deg);
                                tempTable.mapCoef = mapCoef;
                                
                                %determine error.  Values greater than or
                                %less that possible values are mapped to
                                %the nearest real value.  This improves
                                %accuracy.
                                tempTable.error = feval(error_fn, ...
                                    evaluatePolynomial(mapCoef,testingSet(testingIndexes,:).(attributes{mapAttr})),...
                                    testingSet(testingIndexes,:).(attributes{targetAttr}),size(testingIndexes,1));
                            
                                %add tempTable to innerResults
                                innerResults = [innerResults ; tempTable];
                                
                            end
                        end
                    end
                end
            end
            %add innerResults to allInnerResults
            allInnerResults = [allInnerResults ; innerResults];
        end
        
        %find best coef and deg for each mapping from allInnerResults and
        %determine the validation error using the best
        for targetAttr = 1 : size(attributes,2)
            %find all mappings onto targetAttr
            targetAttrResults = allInnerResults((allInnerResults.targetAttr == targetAttr),:);
            
            for mapAttr = 1 : size(attributes,2)
                
                %we don't care about mapping value onto itself since we
                %already know the best mapping
                if targetAttr ~= mapAttr
                    
                    %clearvars that are being recycled
                    clearvars bestMap temp index normValidationSet subjectIDs normProcessedData
                
                    %find all mappings from mapAttr onto targetAttr
                    mapAttrResults = targetAttrResults((targetAttrResults.mapAttr == mapAttr),:);
                
                    %pick the best mapping based upon the previously defined
                    %criteria for best
                    if bestMapPickMethod == 1
                        %pick least error
                        [temp,index] = min(mapAttrResults.error);  
                        bestMap = mapAttrResults(index,:);
                    
                        %pick median error
                    elseif bestMapPickMethod == 2
                        [temp,index] = min(abs(mapAttrResults.error - median(mapAttrResults.error))); 
                        bestMap = mapAttrResults(index,:);
                    
                        %pick max error
                    elseif bestMapPickMethod == 3
                        [temp,index] = max(mapAttrResults.error); 
                        bestMap = mapAttrResults(index,:);
                    
                    else
                        error('you picked an invalid bestMapPickMethod value'); 
                    end
                
                    %normalize all data samples.  We do this instead of
                    %just the validation set, becuase we need to be able to
                    %scale the validation set to compare error results with
                    %non normalized error results.  To do this, we need to
                    %normalize the entire data set.
                    if norm ~= 1
                        normProcessedData = table;
                    
                        %we must normalize differently depending on whether we
                        %are normalizing globally or by user
                        if norm == 2
                            normProcessedData.(attributes{targetAttr}) = (processedData.(attributes{targetAttr}) - ...
                                normAVG(1,targetAttr,bestMap.iteration)) / normSTD(1,targetAttr,bestMap.iteration);
                            normProcessedData.(attributes{mapAttr}) = (processedData.(attributes{mapAttr}) - ...
                                normAVG(1,mapAttr,bestMap.iteration)) / normSTD(1,mapAttr,bestMap.iteration);
                            
                        %because normalizing by user may result in avg or
                        %std of an attibute for that particular user to be
                        %NaN, it is possible that some good samples in the
                        %validation set could become bad samples.  If this
                        %were to happen though, it would mean that the user
                        %has a small number of samples and thus would have
                        %little impact.  We handle this by throwing out
                        %good samples that become bad.  This means that we
                        %need to adjust the number of actual samples from
                        %the validation set that are used to calculate the
                        %error.  The removal of samples that become bad is
                        %done at a later time (not here).
                        elseif norm == 3
                            %get unique users
                            subjectIDs = unique(processedData.patient);
                            normProcessedData = [processedData(:,attributes{targetAttr}) processedData(:,attributes{mapAttr})];
                            
                            %iterate through each user
                            for s = 1 : size(subjectIDs,1)
                                %find user samples in validationSet
                                subjectSamples = (processedData.patient == subjectIDs(s));
                                
                                %for each patient, iterate through all
                                %attributes
                                subjectSet = table;
                                normProcessedData(subjectSamples,attributes{targetAttr}) = ...
                                    array2table((table2array(processedData(subjectSamples,attributes{targetAttr})) - ...
                                    normAVG(s,targetAttr,bestMap.iteration)) / normSTD(s,targetAttr,bestMap.iteration));
                                normProcessedData(subjectSamples,attributes{mapAttr}) = ...
                                    array2table((table2array(processedData(subjectSamples,attributes{mapAttr})) - ...
                                    normAVG(s,mapAttr,bestMap.iteration)) / normSTD(s,mapAttr,bestMap.iteration));
                            end
                        else
                            error('an invalid normalization value is being used');
                        end
                    else
                        %if norm == 1 we don't need to normalize
                        normProcessedData = [processedData(:,attributes{targetAttr}) processedData(:,attributes{mapAttr})];
                    end
                    
                    %assign inf values to nan
                    if size(normProcessedData(isinf(table2array(normProcessedData(:,attributes{targetAttr}))),attributes{targetAttr}),1) ~= 0
                        temp = size(normProcessedData(isinf(table2array(normProcessedData(:,attributes{targetAttr}))),attributes{targetAttr}),1);
                        normProcessedData(isinf(table2array(normProcessedData(:,attributes{targetAttr}))),attributes{targetAttr}).(attributes{targetAttr}) = NaN(temp,1);
                        
                    elseif size(normProcessedData(isinf(table2array(normProcessedData(:,attributes{mapAttr}))),attributes{mapAttr}),1) ~= 0
                        temp = size(normProcessedData(isinf(table2array(normProcessedData(:,attributes{mapAttr}))),attributes{mapAttr}),1);
                        normProcessedData(isinf(table2array(normProcessedData(:,attributes{mapAttr}))),attributes{mapAttr}).(attributes{mapAttr}) = NaN(temp,1);
                    end
                    
                    %scale normalized data to [0,100]
                    normProcessedData.(attributes{targetAttr}) = 100 * ...
                        (normProcessedData.(attributes{targetAttr}) - ...
                        nanmin(normProcessedData.(attributes{targetAttr}))) / ...
                        (nanmax(normProcessedData.(attributes{targetAttr})) - ...
                        nanmin(normProcessedData.(attributes{targetAttr})));
                    normProcessedData.(attributes{mapAttr}) = 100 * ...
                        (normProcessedData.(attributes{mapAttr}) - ...
                        nanmin(normProcessedData.(attributes{mapAttr}))) / ...
                        (nanmax(normProcessedData.(attributes{mapAttr})) - ...
                        nanmin(normProcessedData.(attributes{mapAttr})));
                    
                    %isolate the normalized validation set from the entire
                    %normalized data set
                    normValidationSet = normProcessedData(test(outerCV,outerFolds),:);
                    
                    %using the info from bestMap, map mapAttr
                    mappedNormValidationSet = array2table([evaluatePolynomial( bestMap.mapCoef, ...
                        normValidationSet.(attributes{mapAttr})) normValidationSet.(attributes{targetAttr})]);
                    mappedNormValidationSet.Properties.VariableNames('Var1') = attributes(mapAttr);
                    mappedNormValidationSet.Properties.VariableNames('Var2') = attributes(targetAttr);
                    
                    %notify user if normValidationSet and validationSet are
                    %not the same size
                    if sum(~isnan(validationSet.(attributes{targetAttr}))) ~= sum(~isnan(mappedNormValidationSet.(attributes{targetAttr})))
                        warning('on','all');
                        warning(char(strcat(attributes{targetAttr},{' '},'of',{' '}, ...
                            'Outer fold',{' '},num2str(outerFolds),{' '}, 'using', {' '}, normValues(norm),{' '}, ...
                            'produced a normalized validation set with different size than validation set.', ...
                            {'  '}, 'Mapped normalized validation size is', {' '},  num2str(sum(~isnan(mappedNormValidationSet.(attributes{targetAttr})))), ...
                            {' '}, 'and size of validation is', {' '}, num2str(sum(~isnan(validationSet.(attributes{targetAttr})))))));
                        warning('off','all');
                        
                    elseif sum(~isnan(validationSet.(attributes{mapAttr}))) ~= sum(~isnan(mappedNormValidationSet.(attributes{mapAttr})))
                        warning('on','all');
                        warning(char(strcat(attributes{mapAttr},{' '},'of',{' '}, ...
                            'Outer fold',{' '},num2str(outerFolds),{' '}, 'using', {' '}, normValues(norm),{' '}, ...
                            'produced a normalized validation set with different size than validation set.', ...
                            {'  '}, 'Mapped normalized validation size is', {' '},  num2str(sum(~isnan(mappedNormValidationSet.(attributes{mapAttr})))), ...
                            {' '}, 'and size of validation is', {' '}, num2str(sum(~isnan(validationSet.(attributes{mapAttr})))))));
                        warning('off','all');
                    end
                    
                    %find indexes where mapAttr and targetAttr are not NaN
                    %for the normalized Validation set
                    validationIndexes = ~isnan(mappedNormValidationSet.(attributes{targetAttr}) ...
                        + mappedNormValidationSet.(attributes{mapAttr}));
                    
                    %find validation error
                    bestMap.error = feval(error_fn,mappedNormValidationSet(validationIndexes,:).(attributes{mapAttr}), ...
                        mappedNormValidationSet(validationIndexes,:).(attributes{targetAttr}),size(validationIndexes,1));
                    
                    %store results
                    bestResults = [bestResults; bestMap];
                    
                    %plot poly against validation set
                    if makeGraphs
                        figure((outerFolds - 1) * size(attributes,2) + 3 + targetAttr);
                        subplot(3,3,mapAttr);
                        scatter(normValidationSet.(attributes{mapAttr}),normValidationSet.(attributes{targetAttr}));
                        polyFitX = 1:.1:100;
                        polyFitY = evaluatePolynomial(bestMap.mapCoef,polyFitX);
                        hold on
                        plot(polyFitX,polyFitY,'r');
                        hold off
                        axis([0 100 0 100]);
                        xlabel(attributes{mapAttr});
                        ylabel(attributes{targetAttr});
                        title(strcat('Target' ,{' '}, attributes{targetAttr},{' '},'using',{' '}, normValues{norm}, {', '}, mapStyle{robustFit + 1}, ...
                            {' '}, 'mapping, and', {' '}, bestMapPick{bestMapPickMethod}, {' '}, 'selection'));
                        if mapAttr == size(attributes,2)
                            subplot(3,3,targetAttr);
                            hist(normValidationSet.(attributes{targetAttr}),100);
                            xlim([0 100]);
                            xlabel('Attribute Value');
                            ylabel('Number of Occurances');
                            title(strcat('Validation Set Distribution of' ,{' '}, attributes{targetAttr}, {' '},'using', {' '}, normValues{norm}));
                            savefig(gcf,char(strcat(savePathWtName,{'/'},normValues2{norm},{'/'},'Fold',num2str(outerFolds),{'/'}, ...
                                attributes{targetAttr},mapStyle{robustFit + 1},'MappingByValScatter')));
                            close(gcf);
                        end
                    end
                end
            end
        end
        
        %store results of outer fold
        foldData(:,outerFolds) = table2struct(bestResults);
        
        %display and save attribute distribution per fold results
        if makeGraphs
            figure(2)
            subplot(3,3,outerFolds);
            bar(sum(~ismissing(processedData(training(outerCV,outerFolds),attributes),NaN),1), 'r');
            hold on
            bar(sum(~ismissing(processedData(test(outerCV,outerFolds),attributes),NaN),1),.5, 'g');
            hold off
            set(gca,'XTickLabel',attributes)
            xlabel('Attributes');
            ylabel('Number of Samples');
            legend('Training/Testing','Validation');
            title(strcat(normValues{norm}, {' '}, 'Fold',num2str(outerFolds)));
            savefig(gcf,char(strcat(savePathWtName,{'/'},normValues2{norm},{'/'},'AttributeDistribution')));
        end
    end
    
    if makeGraphs
        f = figure(3);
        for fold = 1 : outerCrossValFolds
            tempTable = struct2table(foldData(:,fold));
            for e = 1 : size(tempTable.error,1)/(size(attributes,2) - 1)
                errorVals = tempTable.error((e - 1) * (size(attributes,2) - 1) + 1 : e * (size(attributes,2) - 1))';
                if e == 1
                    plotVals(fold,:,e) = [0 errorVals];
                elseif e == size(attributes,2)
                    plotVals(fold,:,e) = [errorVals 0];
                else
                    plotVals(fold,:,e) = [errorVals(1:e - 1) 0 errorVals(e:size(attributes,2) - 1)]; 
                end
            end
        end
        plotVals(fold + 1,:,:) = mean(plotVals,1);
        plotVals(fold + 2,:,:) = max(plotVals,[],1);
        plotVals(fold + 3,:,:) = min(plotVals,[],1);
        plotVals(:,size(plotVals,2) + 1,:) = mean(plotVals,2);
        plotVals(:,size(plotVals,2) + 1,:) = std(plotVals(:,1:size(plotVals,2) - 1,:),1,2);
        
        for targetAttr = 1 : size(attributes,2)
            if targetAttr == 1
                pos = [0,585,480,160];
            elseif targetAttr == 2
                pos = [483,585,480,160];
            elseif targetAttr == 3
                pos = [0,420,480,160];
            elseif targetAttr == 4
                pos = [483,420,480,160];
            elseif targetAttr == 5
                pos = [0,255,480,160];
            elseif targetAttr == 6
                pos = [483,255,480,160];
            elseif targetAttr == 7
                pos = [0,90,480,160];
            elseif targetAttr == 8
                pos = [483,90,480,160];
            else
                pos = [965,585,480,160]; 
            end
            
            uitable(f,'Data',[ones(8,1) * targetAttr', plotVals(:,:,targetAttr)], ...
            'RowName',tableRows, 'ColumnName',tableColumns, 'Position', ...
            pos, 'ColumnWidth', {18,35,35,35,35,35,35,35,35,35,35,35});
            
        end
        
        axes('Position',[.69,.35,.3,.3]);
        box on;
        bar(squeeze(plotVals(6,size(plotVals,2) - 1,:)));
        hold on
        bar(squeeze(plotVals(6,size(plotVals,2),:)),.5,'r');
    
        set(gca, 'XTickLabel', attributes);
        legend('MEAN RMSD','STD RMSD');
        set(0, 'currentfigure', f);
        hold off
        box off
        savefig(gcf,char(strcat(savePathWtName,{'/'},normValues2{norm},{'/'},normValues2{norm}, ...
            'Using',mapStyle{robustFit + 1},'Mapping','And',bestMapPick{bestMapPickMethod})));
        close all;
    end

    if saveVariables
        if makeGraphs
            save(char(strcat(savePathWtName,{'/'},normValues2{norm},{'/'},'mapCoefVar')), 'foldData');
        else
            save('mapCoefVar','foldData');
        end
    end
end