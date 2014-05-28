%Author Ryan Brummet
%University of Iowa

function [ RMSDNorm ] = findMapCoefUser( userIndexSet, inputData,...
 trainingSet, testingSet, deg, target)
    
    %we use a training - testing approach when finding RMSDNorm values

    for k = 1 : size(userIndexSet,1)
        %we are using 5-fold cross validation
        clearvars group1 group2 group3 group4 group5
        trainingSetTemp = trainingSet(find(trainingSet(:,1,k)),:,k);
        groupSize = floor(size(trainingSetTemp(:,1),1)/5);
        group(:,:,1) = trainingSetTemp(1 : groupSize,:);
        group(:,:,2) = trainingSetTemp(groupSize + 1 : 2 * groupSize,:);
        group(:,:,3) = trainingSetTemp(2 * groupSize + 1 : 3 * groupSize,:);
        group(:,:,4) = trainingSetTemp(3 * groupSize + 1 : 4 * groupSize,:);
        group(:,:,5) = trainingSetTemp(4 * groupSize + 1 : 5 * groupSize,:);  %we exclude some samples for indexing reasons (no more than 5 max)
        for m = 1 : size(inputData(:,14:size(inputData,2)),2)
            for p = 1 : 5
                currentTrainSize = 0;
                index = 1;
                tempTrainingSet(1,1) = NaN;
                %finding mapping coef for fold
                for c = 1 : 5
                    if c ~= p
                        currentTrainSize = currentTrainSize + size(group(:,:,c),1);
                        for s = 1 : size(group(:,:,c),1)
                            if (group(s,13 + target,c) >= 0 && (group(s,13 + m,c)) >= 0)
                                tempTrainingSet(index,1) = group(s,13 + m,c);
                                tempTrainingSet(index,2) = group(s,13 + target,c);
                                index = index + 1;
                            end
                        end
                    end
                end
                if isnan(tempTrainingSet(1,1))
                    mapCoefTemp(m,:,p) = NaN;
                else
                    mapCoefTemp(m,:,p) = fliplr(polyfit(tempTrainingSet(:,1),tempTrainingSet(:,2),deg));
                end
                clearvars tempTrainingSet
                groupTemp = group;

                %map fold
                for c = 1 : 5
                    for s = 1 : size(group(:,:,c),1)
                        convertedVal = 0;
                        for g = deg: -1: 0
                            convertedVal = convertedVal + (group(s,13 + m,c)^g)*mapCoefTemp(m,g + 1,p);
                        end
                        if convertedVal > 100
                            groupTemp(s,13 + m,c) = 100;
                        elseif convertedVal < 0
                            groupTemp(s,13 + m,c) = 0;
                        else
                            groupTemp(s,13 + m,c) = convertedVal;
                        end
                    end
                end

                %find RMS of training and testing sets of fold
                %train index 1, test index 2
                summation = zeros(1,2);
                maximum = zeros(1,2);
                minimum = zeros(1,2);
                for c = 1 : 5
                    if c ~= p
                        for s = 1 : size(groupTemp(:,:,c),1)
                            if groupTemp(s,13 + m,c) >= 0 && groupTemp(s,13 + target,c) >= 0
                                summation(1) = summation(1) + (groupTemp(s,13 + m,c) - group(s,13 + target,c))^2;
                                if minimum(1) > groupTemp(s,13 + m,c)
                                    minimum(1) = groupTemp(s,13 + m,c);
                                elseif maximum(1) < groupTemp(s,13 + m,c)
                                    maximum(1) = groupTemp(s,13 + m,c);
                                end
                            end
                        end
                    else
                        for s = 1 : size(groupTemp(:,:,c),1)
                            if groupTemp(s,13 + m,c) >= 0 && groupTemp(s,13 + target,c) >= 0
                                summation(2) = summation(2) + (groupTemp(s,13 + m,c) - group(s,13 + target,c))^2;
                                if minimum(2) > groupTemp(s,13 + m,c)
                                    minimum(2) = groupTemp(s,13 + m,c);
                                elseif maximum(2) < groupTemp(s,13 + m,c)
                                    maximum(2) = groupTemp(s,13 + m,c);
                                end
                            end
                        end
                    end
                end
                clearvars groupTemp;
                RMSDNormAttrTemp(p) = (sqrt(summation(1)/currentTrainSize)) / (maximum(1) - minimum(1)) - ...
                    (sqrt(summation(2)/size(group(:,:,p),1))) / (maximum(2) - minimum(2));

            end
            RMSDNormAttrPartition(m) = mean(RMSDNormAttrTemp);
        end
        clearvars group summation maximum minimum RMSDNormAttrTemp
        mapCoef(:,:,k) = mean(mapCoefTemp,3);

        %map training data using averged coef
        mappedTraining = trainingSet(:,:,k);
        mappedTesting = testingSet(:,:,k);
        for m = 1 : size(inputData(:,14:size(inputData,2)),2)
            for s = 1 : size(mappedTraining(:,1),1)
                convertedVal = 0;
                for g = deg: -1: 0
                    convertedVal = convertedVal + (mappedTraining(s,13 + m)^g)*mapCoef(m,g + 1,k);
                end
                if convertedVal > 100
                    mappedTraining(s,13 + m) = 100;
                elseif convertedVal < 0
                    mappedTraining(s,13 + m) = 0;
                else
                    mappedTraining(s,13 + m) = convertedVal;
                end
            end
            for s = 1 : size(mappedTesting(:,1),1)
                convertedVal = 0;
                for g = deg: -1: 0
                    convertedVal = convertedVal + (mappedTesting(s,13 + m)^g)*mapCoef(m,g + 1,k);
                end
                if convertedVal > 100
                    mappedTesting(s,13 + m) = 100;
                elseif convertedVal < 0
                    mappedTesting(s,13 + m) = 0;
                else
                    mappedTesting(s,13 + m) = convertedVal;
                end
            end

            summation = zeros(1,2);
            maximum = zeros(1,2);
            minimum = zeros(1,2);
            %training is index 1, testing is index 2
            for s = 1 : size(mappedTraining,1)
                if mappedTraining(s,13 + m) >= 0 && mappedTraining(s,13 + target) >= 0
                    summation(1) = summation(1) + (mappedTraining(s,13 + m) - trainingSet(s,13 + target))^2;
                    if minimum(1) > mappedTraining(s,13 + m)
                        minimum(1) = mappedTraining(s,13 + m);
                    elseif maximum(1) < mappedTraining(s,13 + m)
                        maximum(1) = mappedTraining(s,13 + m);
                    end
                end
            end
            for s = 1 : size(mappedTesting,1)
                if mappedTesting(s,13 + m) >= 0 && mappedTesting(s,13 + target) >= 0
                    summation(2) = summation(2) + (mappedTesting(s,13 + m) - testingSet(s,13 + target))^2;
                    if minimum(2) > mappedTesting(s,13 + m)
                        minimum(2) = mappedTesting(s,13 + m);
                    elseif maximum(2) < mappedTesting(s,13 + m)
                        maximum(2) = mappedTesting(s,13 + m);
                    end
                end
            end
            RMSDNormAttrTemp(m) = (sqrt(summation(1)/size(testingSet,1))) / (maximum(1) - minimum(1)) - ...
                (sqrt(summation(2)/size(trainingSet,1))) / (maximum(2) - minimum(2));
            
        end
        for m = 1 : size(inputData(:,14:size(inputData,2)),2)
            RMSDNormAttrUser(k,2*m-1) = RMSDNormAttrTemp(m);
            RMSDNormAttrUser(k,2*m) = RMSDNormAttrPartition(m);
        end
        clearvars RMSDNormAttrTemp RMSDNormAttrPartition;
    end
    RMSDNorm = nanmean(RMSDNormAttrUser);
end

