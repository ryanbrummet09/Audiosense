%Ryan Brummet
%University of Iowa

function [ bestMappingPerTarget, bestMappingBySum, bestMappingByAvg ...
    ] = findBestMappingValues2( data, target )

    %data (matrix): contains the processed raw data in the form Patient, 
    %               listening, userInit, ac, lc, tf, vc, tl, nl, rs, cp, 
    %               nz, condition, sp, le, ld, ld2, lcl, ap, qol, im, st
    
    %target (int): if target is a number in [1,9] map onto the attribute
    %               corresponding to that number.  In particular 1:sp, 
    %               2:le, 3:ld, 4:ld2, 5:lcl, 6:ap, 7:q0l, 8:im, 9:st.  If
    %               it isn't, take a brute force approach to find the best
    %               mapping.
    
    
    labels{1} = 'sp';
    labels{2} = 'le';
    labels{3} = 'ld';
    labels{4} = 'ld2';
    labels{5} = 'lcl';
    labels{6} = 'ap';
    labels{7} = 'qol';
    labels{8} = 'im';
    labels{9} = 'st';
    
    if target >= 1 && target <= 9
        start = target;
        ending = target;
    else
        start = 1;
        ending = 9;
    end
    
    %targetAttr, mapAttr, %Samples, deg, mapCoef, RMSD
    %innerResults consists of only results from cross validation of the
    %training set and the resultant RMSD values.  outerResults consists of
    %the best results from innerResults applied to the validation set.
    innerResultIndex = 1;
    outerResultIndex = 1;
    
    %We must create different partitions for cross validation for each
    %targetAttr and mapAttr pair becuase of the large number of holes in
    %our data set
    indexTemp1 = 1;
    for targetAttr = start : ending
        for mapAttr = 1 : 9
            clearvars attrDataSet partition temp outerTrainingSet ...
                trainingGroups validationSet;
            if mapAttr == targetAttr
                continue;
            end
            attrDataSet(1,size(data,2)) = NaN;
            indexTemp2 = 1;
            for n = 1 : size(data,1)
                if ~isnan(data(n,13 + mapAttr)) && ...
                    ~isnan(data(n,13 + targetAttr))
                    attrDataSet(indexTemp2,:) = data(n,:);
                    indexTemp2 = indexTemp2 + 1;
                end
            end
            mapSetSizes(targetAttr, mapAttr) = size(attrDataSet,1);
            indexTemp1 = indexTemp1 + 1;
            clearvars indexTemp2
            
            %build outerTrainingSet and validation set. we use 5 fold cross
            %validation on the data set, then 5 fold cross
            %validation on the outerTrainingSet.
            indices = crossvalind('kfold',size(attrDataSet,1),5);
            index1 = 1;
            index2 = 1;
            index3 = 1;
            index4 = 1;
            index5 = 1;
            
            for k = 1 : size(indices,1)
                if indices(k) == 1
                    partition(index1,:,1) = attrDataSet(k,:);
                    index1 = index1 + 1;
                elseif indices(k) == 2
                    partition(index2,:,2) = attrDataSet(k,:);
                    index2 = index2 + 1;
                elseif indices(k) == 3
                    partition(index3,:,3) = attrDataSet(k,:);
                    index3 = index3 + 1;
                elseif indices(k) == 4
                    partition(index4,:,4) = attrDataSet(k,:);
                    index4 = index4 + 1;
                elseif indices(k) == 5
                    partition(index5,:,5) = attrDataSet(k,:);
                    index5 = index5 + 1;
                else
                    error('Something went horribly, horribly wrong'); 
                end
            end
            
            %pick validation and training sets
            validationSet = partition(:,:,1);
            outerTrainingSet = partition(:,:,2:5);
            
            %partition the outerTrainingSet
            indices = crossvalind('kfold',size(outerTrainingSet,1),5);
            index1 = 1;
            index2 = 1;
            index3 = 1;
            index4 = 1;
            index5 = 1;
            
            for j = 1 : size(indices,1)
                if indices(j) == 1
                    trainingGroups(index1,:,1) = outerTrainingSet(j,:);
                    index1 = index1 + 1;
                elseif indices(j) == 2
                    trainingGroups(index2,:,2) = outerTrainingSet(j,:);
                    index2 = index2 + 1;
                elseif indices(j) == 3
                    trainingGroups(index3,:,3) = outerTrainingSet(j,:);
                    index3 = index3 + 1;
                elseif indices(j) == 4
                    trainingGroups(index4,:,4) = outerTrainingSet(j,:);
                    index4 = index4 + 1;
                elseif indices(j) == 5
                    trainingGroups(index5,:,5) = outerTrainingSet(j,:);
                    index5 = index5 + 1;
                else
                    error('Well, something went really, really wrong');
                end
            end
            
            index = 1;
            temp = zeros(25,11);
            for j = 1 : 5
                clearvars testingSet innerTrainingSet
                %consolidate sets based on traingGroups set to simplify
                %indexing
                if j == 1
                    testingSet = trainingGroups(:,:,1);
                    innerTrainingSet = [trainingGroups(:,:,2); ...
                        trainingGroups(:,:,3); ...
                        trainingGroups(:,:,4); trainingGroups(:,:,5)];
                elseif j == 2
                    testingSet = trainingGroups(:,:,2);
                    innerTrainingSet = [trainingGroups(:,:,1); ...
                        trainingGroups(:,:,3); ...
                        trainingGroups(:,:,4); trainingGroups(:,:,5)];
                elseif j == 3
                    testingSet = trainingGroups(:,:,3);
                    innerTrainingSet = [trainingGroups(:,:,1); ...
                        trainingGroups(:,:,2); ...
                        trainingGroups(:,:,4); trainingGroups(:,:,5)];
                elseif j == 4
                    testingSet = trainingGroups(:,:,4);
                    innerTrainingSet = [trainingGroups(:,:,1); ...
                        trainingGroups(:,:,2); ...
                        trainingGroups(:,:,3); trainingGroups(:,:,5)];
                else
                    testingSet = trainingGroups(:,:,5);
                    innerTrainingSet = [trainingGroups(:,:,1); ...
                        trainingGroups(:,:,2); ...
                        trainingGroups(:,:,3); trainingGroups(:,:,4)];
                end
                    
                for deg = 1 : 5
                    innerResults(innerResultIndex,1) = targetAttr;
                    innerResults(innerResultIndex,2) = mapAttr;
                    innerResults(innerResultIndex,3) = ...
                        size(attrDataSet, 1) / size(data,1) * 100;
                    innerResults(innerResultIndex,4) = deg;
                    mapCoef = polyfit(innerTrainingSet(:,13 + ...
                        mapAttr),innerTrainingSet(:,13 + targetAttr)...
                        ,deg);
                    %save found mapCoef
                    if deg == 1
                        innerResults(innerResultIndex,9) = mapCoef(1);
                            innerResults(innerResultIndex,10) = mapCoef(2);
                    elseif deg == 2
                        innerResults(innerResultIndex,8) = mapCoef(1);
                        innerResults(innerResultIndex,9) = mapCoef(2);
                        innerResults(innerResultIndex,10) = mapCoef(3);
                    elseif deg == 3
                        innerResults(innerResultIndex,7) = mapCoef(1);
                        innerResults(innerResultIndex,8) = mapCoef(2);
                        innerResults(innerResultIndex,9) = mapCoef(3);
                        innerResults(innerResultIndex,10) = mapCoef(4);
                    elseif deg == 4
                        innerResults(innerResultIndex,6) = mapCoef(1);
                        innerResults(innerResultIndex,7) = mapCoef(2);
                        innerResults(innerResultIndex,8) = mapCoef(3);
                        innerResults(innerResultIndex,9) = mapCoef(4);
                        innerResults(innerResultIndex,10) = mapCoef(5);
                    else
                        innerResults(innerResultIndex,5) = mapCoef(1);
                        innerResults(innerResultIndex,6) = mapCoef(2);
                        innerResults(innerResultIndex,7) = mapCoef(3);
                        innerResults(innerResultIndex,8) = mapCoef(4);
                        innerResults(innerResultIndex,9) = mapCoef(5);
                        innerResults(innerResultIndex,10) = mapCoef(6);
                    end
                        
                    %find RMSD
                    summation = 0;
                    for s = 1 : size(testingSet,1)
                        summation = summation + ((innerResults( ...
                            innerResultIndex,5)* ...
                            (testingSet(s,13 + mapAttr)^5) + ...
                            innerResults(innerResultIndex,6) * ...
                            (testingSet(s,13 + mapAttr)^4) + ...
                            innerResults(innerResultIndex,7) * ...
                            (testingSet(s,13 + mapAttr)^3) + ...
                            innerResults(innerResultIndex,8) * ...
                            (testingSet(s,13 + mapAttr)^2) + ...
                            innerResults(innerResultIndex,9) * ...
                            (testingSet(s,13 + mapAttr)) + ...
                            innerResults(innerResultIndex,10)) - (...
                            testingSet(s,13 + targetAttr)))^2;
                    end
                    innerResults(innerResultIndex,11) = sqrt( ...
                        summation / size(testingSet,1));
                    temp(index,:) = innerResults(innerResultIndex,:);
                    index = index + 1;
                    innerResultIndex = innerResultIndex + 1;
                end
            end
            
            %find best coef and deg for this mapping pair from temp
            [minVal,indexMinVal] = min(temp(:,11));
                
            %test against validation set
            summation = 0;
            for s = 1 : size(validationSet,1)
                summation = summation + ((temp(indexMinVal,5)*...
                    (validationSet(s,13 + mapAttr)^5) + ...
                    temp(indexMinVal,6) * ...
                    (validationSet(s,13 + mapAttr)^4) + ...
                    temp(indexMinVal,7) * ...
                    (validationSet(s,13 + mapAttr)^3) + ...
                    temp(indexMinVal,8) * ...
                    (validationSet(s,13 + mapAttr)^2) + ...
                    temp(indexMinVal,9) * ...
                    (validationSet(s,13 + mapAttr)) + ...
                    temp(indexMinVal,10)) - (...
                    validationSet(s,13 + targetAttr)))^2;
            end
            outerResults(outerResultIndex,:) = temp(indexMinVal,:);
            outerResults(outerResultIndex,11) = sqrt(summation / ...
                size(validationSet,1));
            
            %map results if target has been specified
            if target >= 1 && target <= 9
                %build polynomial
                polyFitX = 1:.1:100;
                polyFitY = outerResults(outerResultIndex,5)*(polyFitX.^5) + ...
                    outerResults(outerResultIndex,6)*(polyFitX.^4) + ...
                    outerResults(outerResultIndex,7)*(polyFitX.^3) + ...
                    outerResults(outerResultIndex,8)*(polyFitX.^2) + ...
                    outerResults(outerResultIndex,9)*(polyFitX.^1) + ...
                    outerResults(outerResultIndex,10)*(polyFitX.^0);
                
                %figure one has all data points
                figure(1)
                subplot(3,3,mapAttr);
                scatter(attrDataSet(:,13 + mapAttr),attrDataSet(:, 13 + ...
                    targetAttr),'r');
                hold on
                plot(polyFitX,polyFitY);
                hold off;
                ylabel(labels{targetAttr});
                xlabel(labels{mapAttr});
                title('All Data Samples');
                axis([0 100 0 100]);
                
                %figure two has only validation points
                figure(2)
                subplot(3,3,mapAttr);
                scatter(validationSet(:,13 + mapAttr), validationSet(:, ...
                    13 + targetAttr),'r');
                hold on;
                plot(polyFitX,polyFitY);
                hold off;
                ylabel(labels{targetAttr});
                xlabel(labels{mapAttr});
                title('Validation Data Samples');
                axis([0 100 0 100]);
            end
            outerResultIndex = outerResultIndex + 1;
        end
    end
    
    %at this point we have data from a brute force analysis of mapping
    %pairs.  We need to disseminate the data to find the best mapping.
    %First we divide the data we collected into groups by targetAttr (so
    %there are 9 groups).  We do this for both the inner and outer results.
    %Our final results will be from the outer results.  We will use our
    %analysis of the inner results to create a few box plots to give
    %graphical view of all the entirity of the results.
    index1 = 1;
    index2 = 1;
    index3 = 1;
    index4 = 1;
    index5 = 1;
    index6 = 1;
    index7 = 1;
    index8 = 1;
    index9 = 1;
    for k = 1 : size(outerResults,1)
        if ~isnan(outerResults(k,1))
            if outerResults(k,1) == 1
                sortedOuterResults(index1,:,1) = outerResults(k,:);
                index1 = index1 + 1;
            elseif outerResults(k,1) == 2
                sortedOuterResults(index2,:,2) = outerResults(k,:);
                index2 = index2 + 1;
            elseif outerResults(k,1) == 3
                sortedOuterResults(index3,:,3) = outerResults(k,:);
                index3 = index3 + 1;
            elseif outerResults(k,1) == 4
                sortedOuterResults(index4,:,4) = outerResults(k,:);
                index4 = index4 + 1;
            elseif outerResults(k,1) == 5
                sortedOuterResults(index5,:,5) = outerResults(k,:);
                index5 = index5 + 1;
            elseif outerResults(k,1) == 6
                sortedOuterResults(index6,:,6) = outerResults(k,:);
                index6 = index6 + 1;
            elseif outerResults(k,1) == 7
                sortedOuterResults(index7,:,7) = outerResults(k,:);
                index7 = index7 + 1;
            elseif outerResults(k,1) == 8
                sortedOuterResults(index8,:,8) = outerResults(k,:);
                index8 = index8 + 1;
            else
                sortedOuterResults(index9,:,9) = outerResults(k,:);
                index9 = index9 + 1;
            end
        end
    end
    
    index1 = 1;
    index2 = 1;
    index3 = 1;
    index4 = 1;
    index5 = 1;
    index6 = 1;
    index7 = 1;
    index8 = 1;
    index9 = 1;
    for k = 1 : size(innerResults,1)
        if ~isnan(innerResults(k,1))
            if innerResults(k,1) == 1
                sortedInnerResults(index1,:,1) = innerResults(k,:);
                index1 = index1 + 1;
            elseif innerResults(k,1) == 2
                sortedInnerResults(index2,:,2) = innerResults(k,:);
                index2 = index2 + 1;
            elseif innerResults(k,1) == 3
                sortedInnerResults(index3,:,3) = innerResults(k,:);
                index3 = index3 + 1;
            elseif innerResults(k,1) == 4
                sortedInnerResults(index4,:,4) = innerResults(k,:);
                index4 = index4 + 1;
            elseif innerResults(k,1) == 5
                sortedInnerResults(index5,:,5) = innerResults(k,:);
                index5 = index5 + 1;
            elseif innerResults(k,1) == 6
                sortedInnerResults(index6,:,6) = innerResults(k,:);
                index6 = index6 + 1;
            elseif innerResults(k,1) == 7
                sortedInnerResults(index7,:,7) = innerResults(k,:);
                index7 = index7 + 1;
            elseif innerResults(k,1) == 8
                sortedInnerResults(index8,:,8) = innerResults(k,:);
                index8 = index8 + 1;
            else
                sortedInnerResults(index9,:,9) = innerResults(k,:);
                index9 = index9 + 1;
            end
        end
    end
    
    if target >= 1 && target <= 9
        bestMappingBySum = sortedOuterResults(:,:,target);
        bestMappingByAvg = sortedOuterResults(:,:,target);
    else
        %find best mapping by sum and avg
        for k = 1 : 9
            RMSDSum(k) = sum(sortedOuterResults(:,11,k)); 
            RMSDMean(k) = mean(sortedOuterResults(:,11,k));
        end
        [minVal, indexMinVal] = min(RMSDSum);
        bestMappingBySum = sortedOuterResults(:,:,indexMinVal);
        [minVal, indexMinVal] = min(RMSDMean);
        bestMappingByAvg = sortedOuterResults(:,:,indexMinVal);
    end
    bestMappingPerTarget = sortedOuterResults;
    
end