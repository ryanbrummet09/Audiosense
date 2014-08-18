%Ryan Brummet
%University of Iowa

%preprocesses the model before any rank defficiencies are removed and the
%dataset is partitioned into training and validation sets

function [ processedData, outerCV ] = preProcessesData4Model( dataFileName, demo1FileName, ...
    demo2FileName, predictors, numericPredictors, responses, removeFifties, omitListening, omitNotListening, ...
    omitUserInit, omitNotUserInit, omitWearingHearingAid, omitNotWearingHearingAid, ...
    minNumSamplesPerUser, necessaryPredictors, keepDummyVars, convertdB, modelType)

    %this value is still included so that a function runs correctly, but is not
    %longer used or needed.  I decided to stop putting limitations on how long
    %a user could spend taking a survey
    minPercentOfDurationFromMean = .5;    %all samples must be in the interval [avgDuration - duration*this, avgDuration + duration*this]

    %defines how how big our training and validation sets will be (5 means 80%
    %in training, 20% in validation)
    outerCrossValFolds = 5;

    %defines how data should be grouped, if at all, before splitting into
    %training and validation sets
    %IF CONDITION IS PRESENT IT MUST BE PLACED LAST IN THE VECTOR
    groupVars = {'patient','condition'};
    
    %if true, the data set is randomized by row before the training and
    %validation sets are created
    randomizeDataSampleOrder = true;
    
    extractedColNames = [predictors responses];

    load(dataFileName);
    load(demo1FileName);
    load(demo2FileName);
    
    %convert db to magnitude (logrithmic to linear)
    if convertdB
        demographics.SNRLossLeft = db2mag(demographics.SNRLossLeft);
        demographics.SNRLossRight = db2mag(demographics.SNRLossRight);
        pta.pta124Left = db2mag(pta.pta124Left);
        pta.pta124Right = db2mag(pta.pta124Right);
        pta.pta512Left = db2mag(pta.pta512Left);
        pta.pta512Right = db2mag(pta.pta512Right);
    end

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
        for k = 1 : size(responses,2)
            unProcessedData((unProcessedData.(responses{k}) == 50) ...
                & (unProcessedData.timestamp < fiftyCorrectionDate),:) = [];
        end
    end
    
    %remove samples where all responses are NaN
    toBeRemoved = zeros(size(unProcessedData,1),1);
    for k = 1 : size(responses,2)
        toBeRemoved = isnan(unProcessedData.(responses{k})) + toBeRemoved;
    end
    unProcessedData = unProcessedData(toBeRemoved < size(responses,2),:);

    %remove samples with users with an insufficient number of samples
    [unProcessedData] = removeNonQualUsers(unProcessedData,minNumSamplesPerUser);
    
    %remove samples where ac, lc, or nz are NaN.  This should not occur so
    %if this happens a warning is given
    checkPredictors = {'ac','lc','nz'};
    for k = 1 : size(checkPredictors,2)
        if sum(ismember(predictors,checkPredictors)) == 1
            unProcessedData(isnan(unProcessedData.(checkPredictors{k})),:) = [];
            warning(char(strcat({'The '},checkPredictors{k},{' feature has NaN samples'}))); 
        end
    end
    
    %here we add the demo data into unProcessedData
    demoNames = demographics.Properties.VariableNames;
    demoNames(strcmp(demoNames,'patient')) = [];
    ptaNames = pta.Properties.VariableNames;
    ptaNames(strcmp(ptaNames,'patient')) = [];
    patientID = unProcessedData.patient(1);
    demoIndex = (demographics.patient == patientID);
    ptaIndex = (pta.patient == patientID);
    demoData = [demographics(demoIndex,demoNames), pta(ptaIndex,ptaNames)];
    for k = 2 : size(unProcessedData,1)
        patientID = unProcessedData.patient(k);
        demoIndex = (demographics.patient == patientID);
        ptaIndex = (pta.patient == patientID);
        demoData = [demoData; [demographics(demoIndex,demoNames), pta(ptaIndex,ptaNames)]];
    end 
    unProcessedData = [demoData unProcessedData];

    %randomize the row order of the matrix
    if randomizeDataSampleOrder
        unProcessedData = unProcessedData(randperm(size(unProcessedData,1)),:);
    end
    
    %reasign attr values so that large values are 'good' and small values are
    %'bad'.
    unProcessedData.le = 100 - unProcessedData.le;
    unProcessedData.ap = 100 - unProcessedData.ap;

    conditionVals = unProcessedData.condition;
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
        
        %we recode condition99 as condition0 so that it will be treated as the
        %reference variable after dummy encoding by the built in matlab code
        elseif conditionVals(k,1) == 99
            conditionVals(k,1) = 0; 
        end
    end
    unProcessedData.condition = conditionVals;
    
    %make sure that there are no NaN condition samples
    if sum(isnan(unProcessedData.condition)) > 0
        error('NaN condition values detected and removed');
        unProcessedDate(isnan(unProcessedData.condition),:) = [];
    end
    
    %convert listening to numeric
    if sum(ismember(predictors,'listening')) == 1
        unProcessedData.listening(strcmp(unProcessedData.listening,''),1) = {'NaN'};
        unProcessedData.listening = str2num(char(unProcessedData.listening)) + 1;
    end
    
    %convert userinitiated to numeric
    if sum(ismember(predictors,'userinitiated')) == 1
        unProcessedData.userinitiated(strcmp(unProcessedData.userinitiated,''),1) = {'NaN'};
        unProcessedData.userinitiated = str2num(char(unProcessedData.userinitiated)) + 1;
    end
    
    
    %convert predictor NaN values to 0
    for k = 1 : size(predictors,2)
        temp = unProcessedData.(predictors{k});
        temp(isnan(temp)) = 0;
        unProcessedData.(predictors{k}) = temp;
    end
    
    %build grouping feature
    cvVar = zeros(size(unProcessedData,1),1);
    for cs = 0 : size(groupVars,2) - 1
        if strcmp(char(groupVars{cs + 1}),'patient') || strcmp(char(groupVars{cs + 1}),'condition')
            if strcmp(char(groupVars{cs + 1}),'patient')
                cvVar = cvVar + unProcessedData.patient;
            else
                cvVar = cvVar + unProcessedData.(groupVars{cs + 1}) * 10 ^ (-cs - 1);
            end
        else
            cvVar = cvVar + unProcessedData.(groupVars{cs + 1}) * 10 ^ (-cs);
        end
    end
    unProcessedData.cvVar = cvVar;
    temp = num2str(unique(unProcessedData.cvVar));
    
    %build partition for training and validation sets
    outerCV = cvpartition(nominal(unProcessedData.cvVar,temp),'kfold',outerCrossValFolds);
    unProcessedData.cvVar = [];
    
    %extract relevant columns
    processedData = unProcessedData(:,extractedColNames);
    
    %% Create Dummy Variables, Identify and Remove Linear Dependent Dummy Variables, and Combine into Categorical Matrix
    if ~strcmp(modelType,'stepwise')
        %first we need to find how many possibilities there are for
        %each predictor variable
        for k = 1 : size(predictors,2)
            if ~ismember(predictors(k),numericPredictors)
                temp = unique(processedData.(predictors{k}));
                temp(temp == 0) = [];
                amount(k) = size(temp(~isnan(temp)),1);
            else
                amount(k) = 1; 
            end
        end

        %next we create the dummy variables
        dummyVars = zeros(size(processedData,1),sum(amount));
        for k = 1 : size(processedData,1)
            for j = 1 : size(predictors,2)
                if ~ismember(predictors(j),numericPredictors)
                    temp = unique(processedData.(predictors{j}));
                    temp(temp == 0) = [];
                    if j == 1
                        dummyVars(k,find(temp == processedData.(predictors{j})(k))) = 1;
                    else
                        dummyVars(k,sum(amount(1:j - 1)) + find(temp == processedData.(predictors{j})(k))) = 1;
                    end
                else
                    dummyVars(k,sum(amount(1:j))) = processedData.(predictors{j})(k);
                end
            end
        end

        %here we name the dummy variables (we also turn dummyVars into a table)
        dummyVars = array2table(dummyVars);
        index = 1;
        for k = 1 : size(predictors,2)
            temp = unique(processedData.(predictors{k}));
            temp(temp == 0) = [];
            if amount(k) ~= 1
                for j = 1 : amount(k)
                    dummyVars.Properties.VariableNames{strcat('dummyVars',num2str(index))} = strcat(predictors{k},num2str(temp(j)));
                    index = index + 1;
                end
            else
                dummyVars.Properties.VariableNames{strcat('dummyVars',num2str(index))} = predictors{k};
                index = index + 1;
            end
        end

        %here we remove linearly dependent dummy features.  However, we do not
        %remove dummy features that are members of the elements of the sets
        %necessaryPredictors or numericPredictors.  We first check to see that we can
        %include all elements that are in necessaryPredictors and numericPredictors.  If not an error is
        %thrown
        numToBeRemoved = size(dummyVars,2) - rank(table2array(dummyVars));
        if numToBeRemoved > 0
            dummyVarsTemp = dummyVars;
            keptPredictors = table;
            for k = 1 : size(numericPredictors,2)
                keptPredictors.(numericPredictors{k}) = dummyVars.(numericPredictors{k});
                dummyVarsTemp.(numericPredictors{k}) = [];
            end
            for k = 1 : size(necessaryPredictors,2)
                temp = unique(processedData.(necessaryPredictors{k}));
                temp(temp == 0) = [];
                for j = 1 : size(temp,1)
                    predictorName = strcat(necessaryPredictors{k},num2str(temp(j)));
                    keptPredictors.(predictorName) = dummyVars.(predictorName);
                    dummyVarsTemp.(predictorName) = [];
                end
            end
            if rank(table2array(keptPredictors)) == size(keptPredictors,2)
                dummyNames = dummyVarsTemp.Properties.VariableNames;
                for k = 1 : size(dummyVarsTemp,2)
                    keptPredictors.(dummyNames{k}) = dummyVarsTemp.(dummyNames{k});
                    if rank(table2array(keptPredictors)) == size(keptPredictors,2)
                        dummyVarsTemp.(dummyNames{k}) = []; 
                    else
                        keptPredictors.(dummyNames{k}) = []; 
                    end
                end
            else
                error('Linear dependence detected within matrix composed of only necessary predictors');
            end
        else
            keptPredictors = dummyVars; 
        end
    
        if keepDummyVars
            processedData = [keptPredictors,processedData(:,responses),processedData(:,'patient')]; 
            return;
        end

        %here we recombine are dummy variables to increase execution time
        linDepDummyVars = dummyVarsTemp.Properties.VariableNames;
        for k = 1 : size(linDepDummyVars,2)
            if size(linDepDummyVars{k},2) == 3
                value = str2num(linDepDummyVars{k}(3:size(linDepDummyVars{k},2)));
                temp = processedData.(linDepDummyVars{k}(1:2));
                temp(temp == value) = 0;
                processedData.(linDepDummyVars{k}(1:2)) = temp;
            else
                if strcmp(linDepDummyVars{k}(1:3),'pat')
                    value = str2num(linDepDummyVars{k}(8:size(linDepDummyVars{k},2)));
                    temp = processedData.patient;
                    temp(temp == value) = 0;
                    processedData.patient = temp;
                elseif strcmp(linDepDummyVars{k}(1),'c')
                    value = str2num(linDepDummyVars{k}(10:size(linDepDummyVars{k},2)));
                    temp = processedData.condition;
                    temp(temp == value) = 0;
                    processedData.condition = temp;
                elseif strcmp(linDepDummyVars{k}(1),'u')
                    value = str2num(linDepDummyVars{k}(14:size(linDepDummyVars{k},2)));
                    temp = processedData.userinitiated;
                    temp(temp == value) = 0;
                    processedData.userinitiated = temp;
                else
                    processedData.(linDepDummyVars{k}) = []; 
                end
            end
        end

        %here we make our predictors categorical variables we will use full
        %dummy encoding so we don't need to specify the reference
        for k = 1 : size(predictors,2)
            if ~ismember(predictors(k),numericPredictors)
                temp = unique(processedData.(predictors{k}))';
                processedData.(predictors{k}) = categorical(processedData.(predictors{k}),temp);
            end
        end
 
    else
        %stepwise regression handles linear dependence so we only need to
        %make our predictor variables categorical
         for k = 1 : size(predictors,2)
             if ~ismember(predictors(k),numericPredictors)
                  temp = unique(processedData.(predictors{k}))';
                  temp(temp == 0) = [];
                  processedData.(predictors{k}) = categorical(processedData.(predictors{k}),[0 temp]);
             end
         end
    end
        
    %here we add patient to processedData as a predictor for options that
    %may need to be satisfied later.  Patient may or may not be removed
    %based upon selected options.  It is only added if it isn't present
    %already
    if sum(ismember(processedData.Properties.VariableNames,'patient')) == 0
        processedData.patient = unProcessedData.patient;
    end
end

