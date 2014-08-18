%Ryan Brummet
%University of Iowa

%% initialize
close all;
clear;
clc;

combineTech = 'AVG';  %can be SUMADJ, AVG, MEDIAN, or STD
targetAttr = 'le';  %NoMap for no map otherwise one of {'sp','le','ld2','lcl','ap','st'};
normTech = 'NoNorm';  %can be NoNorm, GlobalNorm, or UserNorm;
mapTech = 'polyMappingGraphs';  %can be robustMappingGraphs polyMappingGraphs robustMappingGraphsWtOut_______(list attr) or polyMappingGraphsWtOut______(list attr)
mapBool = false;
fixHA = false;

if strcmp(normTech,'NoNorm')
    normTech2 = 'notNormalized';
elseif strcmp(normTech,'GlobalNorm')
    normTech2 = 'globallyNormalized';
elseif strcmp(normTech,'UserNorm');
    normTech2 = 'userNormalized';
else
    error('an invalid value for normTech was given'); 
end


makeGraphs = true;
outputVarFileName = char(strcat('compositeScoreOn_',targetAttr,'_Using',combineTech,normTech));
dataFileName = 'DataTable.mat';  %must be .mat file, variable must be 'unProcessedData'
mapInfoFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/',mapTech,'/',normTech2,'/mapCoefVar.mat'));; 
removeFifties = true;
omitListening = false;
omitNotListening = false;
omitUserInit = false;
omitNotUserInit = false;
omitWearingHearingAid = false;
omitNotWearingHearingAid = false;
minNumSamplesPerUser = 50;   %a user not having this # of samples has all samples removed
minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]


if strcmp(normTech,'NoNorm')
    norm = 1;
elseif strcmp(normTech,'GlobalNorm')
    norm = 2;
elseif strcmp(normTech,'UserNorm')
    norm = 3;
else
    error('invalid norm Tech'); 
end

outerCrossValFolds = 5;
innerCrossValFolds = 5;

%IF CONDITION IS PRESENT IN groupVars, IT MUST APEAR LAST IN THE VECTOR
groupVars = {'ac','lc','nz','patient','condition'};  %used to build a composite variable that is used to statify in cross validation
randomizeDataSampleOrder = true;

%1 for avg, 2 for sum, 3 for median, 4 for std, %MIN DOES NOT WORK SO IT IS LIKELY THAT MAX DOESN'T AS WELL
if strcmp(combineTech,'AVG')
    combineScoreTechnique = 1;
elseif strcmp(combineTech,'SUMADJ')
    combineScoreTechnique = 2;
elseif strcmp(combineTech,'MEDIAN')
    combineScoreTechnique = 3;
elseif strcmp(combineTech,'STD')
    combineScoreTechnique = 4;
else
    error('invalid combine Tech'); 
end 

saveLocation = {char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/',mapTech,'/',normTech2,'/','combinedScoreUsing',combineTech,targetAttr,'/'))};

%% global variables
%we remove ld, im, and qol becuase scores from these attr do not reflect HA
%performance
attributes = {'sp', 'le', 'ld2', 'lcl', 'ap', 'st'}; %{'sp', 'le', 'ld', 'ld2', 'lcl', 'ap', 'qol', 'im', 'st'}
contexts = {'hau', 'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
miscDataInfo = {'patient', 'listening', 'userinitiated', 'hau',};
combineScoreInfo = {'AVG', 'SUM', 'MEDIAN', 'STD', 'MAX', 'MIN'};
extractedColNames = [miscDataInfo contexts attributes];

%% preprocess data
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
         unProcessedData((unProcessedData.(attributes{k}) == 50) ...
             & (unProcessedData.timestamp < fiftyCorrectionDate),:) = [];
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

%reasign attr values so that large values are 'good' and small values are
%'bad'.
unProcessedData.le = 100 - unProcessedData.le;
unProcessedData.ap = 100 - unProcessedData.ap;

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

%clear variables that are no longer needed
clearvars fiftyCorrectionDate unProcessedData 

%% Normalize Data
%for simplicity we pick the first partition of the inner and outer training
%sets.  In reality, we don't need an inner and outer training set, but we
%want to be consistent with how we generated our map Coef values
cvVar = zeros(size(processedData,1),1);
for cs = 0 : size(groupVars,2) - 1
    if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
        if strcmp(char(groupVars{cs + 1}),'patient')
            cvVar = cvVar + processedData.patient;
        else
            cvVar = cvVar + processedData.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
        end
        
    else
        cvVar = cvVar + processedData.(groupVars{cs + 1}) * 10 ^ (-cs);
    end
end
processedData.cvVar = cvVar;

outerCV = cvpartition(processedData.cvVar,'kfold',outerCrossValFolds);
outerTrainingSet = processedData(training(outerCV,1),:);
innerCV = cvpartition(outerTrainingSet.cvVar,'kfold',innerCrossValFolds);

if norm ~= 1
    [ normData, normAVG, normSTD ] = normalizeDataAndFindNormVals( processedData, ...
        outerTrainingSet, attributes, innerCV, 1, norm );
else
    [ normData, normAVG, normSTD ] = normalizeDataAndFindNormVals( processedData, ...
        outerTrainingSet, attributes, innerCV, 1, 3 );
    clearvars normData;
    normData = processedData; 
end


%% map attributes
%first we need to find and extract the relevant mapCoef.  For simplicity we
%look at only the first fold.  If we are not mapping we just combine using
%the given method.
if mapBool
    load(mapInfoFileName);
    targetAttr = find(strcmp(attributes,targetAttr));
    index = 1;
    for i = 1 : size(foldData,1)
        if foldData(i,1).targetAttr == targetAttr
            relevantMapInfo(index,:) = struct2table(foldData(i,1));
            index = index + 1;
        end
    end

    %now that we have the relevant mapCoef and have normalized we map
    %attributes
    combinedScoreData = normData;
    for i = 1 : size(attributes,2)
        if targetAttr ~= i
            index = find(relevantMapInfo.mapAttr == i);
            combinedScoreData.(attributes{i}) = evaluatePolynomial(relevantMapInfo(index,:).mapCoef, normData.(attributes{i}));
        end
    end
else
    combinedScoreData = normData;
end

%extract normalized, mapped attributes
for k = 1 : size(attributes,2)
    normMappedAttr(:,k) = combinedScoreData.(attributes{k}); 
end

%produce combined Score
if combineScoreTechnique == 1
    combinedAttr = nanmean(normMappedAttr')';
elseif combineScoreTechnique == 2
    combinedAttr = nansum(normMappedAttr')' ./ sum((~isnan(normMappedAttr))')';
elseif combineScoreTechnique == 3
    combinedAttr = nanmedian(normMappedAttr')';
elseif combineScoreTechnique == 4
    combinedAttr = nanstd(normMappedAttr')';
elseif combineScoreTechnique == 5
    combinedAttr = nanmax(normMappedAttr')';
elseif combineScoreTechnique == 6
    combinedAttr = nanmin(normMappedAttr')';
else
    error('An invalid combineScoreTechnique was used'); 
end


%put combined scores with context info
for k = 1 : size(attributes,2)
    combinedScoreData.(attributes{k}) = [];
end
combinedScoreData.score = combinedAttr;

%convert true false cells to num
combinedScoreData.hau(strcmp(combinedScoreData.hau,''),1) = {'NaN'};
combinedScoreData.hau = str2num(char(combinedScoreData.hau)) + 1;
combinedScoreData.listening(strcmp(combinedScoreData.listening,''),1) = {'NaN'};
combinedScoreData.listening = str2num(char(combinedScoreData.listening)) + 1;
combinedScoreData.userinitiated(strcmp(combinedScoreData.userinitiated,''),1) = {'NaN'};
combinedScoreData.userinitiated = str2num(char(combinedScoreData.userinitiated)) + 1;

%here we rescale the combined scores to spread them out and to put them
%onto a consistent interval
%combinedScoreData.score = 100 * (combinedScoreData.score - min(combinedScoreData.score)) / ...
%    (max(combinedScoreData.score) - min(combinedScoreData.score));

clearvars combinedAttr normMappedAttr index i k relevantMapInfo 

if fixHA
    combinedScoreData = combinedScoreData(combinedScoreData.condition == 5,:); 
end

if makeGraphs
    mkdir(char(saveLocation)); 
    
    %make histogram
    hist(combinedScoreData.score, 100);
    title(char(strcat('Distribution of combined Scores Using', {' '}, combineScoreInfo{combineScoreTechnique})));
    xlabel('Score');
    ylabel('Count');
    savefig(gcf,char(strcat(saveLocation,'scoreDistribution','_NoHA')));
    close all;
    
    %distribution per context category
    mkdir(char(strcat(saveLocation,'contextVarDist')));
    for k = 1 : size(contexts,2)
        contextValues = unique(combinedScoreData.(contexts{k}));
        contextValues(isnan(contextValues)) = [];
        plotVals = nan(size(combinedScoreData,1),size(contextValues,1));
        for j = 1 : size(combinedScoreData,1)
            if ~isnan(combinedScoreData.(contexts{k})(j))
                if ~strcmp(contexts{k},'condition')
                    plotVals(j,combinedScoreData.(contexts{k})(j)) = combinedScoreData.score(j);
                else
                    plotVals(j,find(contextValues == combinedScoreData.(contexts{k})(j))) = combinedScoreData.score(j);
                end
            end
        end
        boxplot(plotVals, 'labels', contextValues);
        title(char(strcat(contexts{k}, {' '}, 'Combined Score Distribution Using', {' '}, combineScoreInfo{combineScoreTechnique})));
        xlabel('Context Value');
        savefig(gcf,char(strcat(saveLocation,'contextVarDist/',contexts{k},'ScoreBoxPlot','_NoHA')));
        close all;
    end
    
    %distribution per user
    plotVals = nan(size(combinedScoreData,1),size(unique(combinedScoreData.patient),1));
    for j = 1 : size(combinedScoreData,1)
        plotVals(j,combinedScoreData.patient(j)) = combinedScoreData.score(j); 
    end
    boxplot(plotVals);
    title(char(strcat('Patient Score Distribution Using', {' '}, combineScoreInfo{combineScoreTechnique})));
    xlabel('User');
    savefig(gcf,char(strcat(saveLocation,'userScoreBoxPlot','_NoHA')));
    close all;
end

validationSet = combinedScoreData(test(outerCV,1),:);
trainingSet = combinedScoreData(training(outerCV,1),:);
save(char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/',outputVarFileName)),'validationSet','trainingSet','normAVG','normSTD','combinedScoreData');
