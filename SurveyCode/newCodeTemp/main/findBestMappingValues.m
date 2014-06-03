%Ryan Brummet
%University of Iowa

function [ ] = findBestMappingValues( data )

    %data (matrix): contains the processed raw data in the form Patient, 
    %               listening, userInit, ac, lc, tf, vc, tl, nl, rs, cp, 
    %               nz, condition, sp, le, ld, ld2, lcl, ap, qol, im, st
    
    %ONLY SUPPORTS 5-FOLD CROSS VALIDATION!!!
    
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
    for targetAttr = 1 : 9
        for mapAttr = 1 : 9
            clearvars attrDataSet validationGroups;
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
                    validationGroups(index1,:,1) = attrDataSet(k,:);
                    index1 = index1 + 1;
                elseif indices(k) == 2
                    validationGroups(index2,:,2) = attrDataSet(k,:);
                    index2 = index2 + 1;
                elseif indices(k) == 3
                    validationGroups(index3,:,3) = attrDataSet(k,:);
                    index3 = index3 + 1;
                elseif indices(k) == 4
                    validationGroups(index4,:,4) = attrDataSet(k,:);
                    index4 = index4 + 1;
                elseif indices(k) == 5
                    validationGroups(index5,:,5) = attrDataSet(k,:);
                    index5 = index5 + 1;
                else
                    error('Something went horribly, horribly wrong'); 
                end
            end
            
            for k = 1 : 5
                
                %consolidate sets based on current validation set to simplify
                %indexing
                clearvars validationSet outerTrainingSet index1 index2 index3 ...
                index4 index5 indices trainingGroups
            
                if k == 1 
                    validationSet = validationGroups(:,:,1);
                    outerTrainingSet = [validationGroups(:,:,2); ...
                        validationGroups(:,:,3);validationGroups(:,:,4);...
                        validationGroups(:,:,5)];
                elseif k == 2
                    validationSet = validationGroups(:,:,2);
                    outerTrainingSet = [validationGroups(:,:,1); ...
                        validationGroups(:,:,3);validationGroups(:,:,4);...
                        validationGroups(:,:,5)];
                elseif k == 3
                    validationSet = validationGroups(:,:,3);
                    outerTrainingSet = [validationGroups(:,:,1); ...
                        validationGroups(:,:,2);validationGroups(:,:,4);...
                        validationGroups(:,:,5)];
                elseif k == 4
                    validationSet = validationGroups(:,:,4);
                    outerTrainingSet = [validationGroups(:,:,1); ...
                        validationGroups(:,:,2);validationGroups(:,:,3);...
                        validationGroups(:,:,5)];
                else
                    validationSet = validationGroups(:,:,5);
                    outerTrainingSet = [validationGroups(:,:,1); ...
                        validationGroups(:,:,2);validationGroups(:,:,3);...
                        validationGroups(:,:,4)];
                end
                
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
                
                %find RMSD with bext coef and deg of validation set
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
                outerResultIndex = outerResultIndex + 1;
            end
        end
    end
    
    f = figure;
    %build tables
    tableColumns = {'TARGET';'SP';'LE';'LD';'LD2';'LCL';'AP';'QOL';'IM' ...
        ;'ST'};
    tableRows = {'Fold 1';'Fold 2';'Fold 3';'Fold 4';'Fold 5'; ...
        'Avg';'Max';'Min'};
    for targetAttr = 1 : 9
        clearvars temp tempIndex;
        for mapAttr = 1 : 9
            if targetAttr ~= mapAttr
                tempIndex = 1;
                for k = 1 : size(outerResults,1)
                    if outerResults(k,1) == targetAttr && outerResults( ...
                            k,2) == mapAttr
                        temp(tempIndex,:,mapAttr) = outerResults(k,:);
                        tempIndex = tempIndex + 1;
                    end
                end
                
            else
              temp(1:5,:,mapAttr) = zeros(5,size(outerResults,2));  
            end
        end
        for k = 1 : 9
            if k == 1 
                temp(size(temp,1) + 1,11,k) = sum(temp(:,11,k))/5;
                temp(size(temp,1) + 1,11,k) = max(temp(1:size(temp,1) - 1, ...
                    11,k));
                temp(size(temp,1) + 1,11,k) = min(temp(1:size(temp,1) - 2, ...
                    11,k));
            else
                temp(size(temp,1) - 2,11,k) = sum(temp(:,11,k))/5;
                temp(size(temp,1) - 1,11,k) = max(temp(1:size(temp,1) - 1, ...
                    11,k));
                temp(size(temp,1),11,k) = min(temp(1:size(temp,1) - 2, ...
                    11,k));
            end
        end
        if targetAttr == 1
            pos = [0,585,460,160];
        elseif targetAttr == 2
            pos = [465,585,460,160];
        elseif targetAttr == 3
            pos = [0,420,460,160];
        elseif targetAttr == 4
            pos = [465,420,460,160];
        elseif targetAttr == 5
            pos = [0,255,460,160];
        elseif targetAttr == 6
            pos = [465,255,460,160];
        elseif targetAttr == 7
            pos = [0,90,460,160];
        elseif targetAttr == 8
            pos = [465,90,460,160];
        else
            pos = [930,585,460,160]; 
        end
        
        uitable(f,'Data',[ones(8,1) * targetAttr, ...
            temp(:,11,1),temp(:,11,2),temp(:,11,3), ...
            temp(:,11,4),temp(:,11,5),temp(:,11,6), ...
            temp(:,11,7),temp(:,11,8),temp(:,11,9)], ...
            'RowName',tableRows, 'ColumnName',tableColumns, 'Position', ...
            pos, 'ColumnWidth', {20,40,40,40,40,40,40,40,40,40});
        
        combinedError(targetAttr,1) = mean(temp(6,11,1:9));
        combinedError(targetAttr,2) = std(temp(6,11,1:9));
        
    end
    
    axes('Position',[.67,.35,.3,.3]);
    box on;
    bar([combinedError(1,1) combinedError(2,1) combinedError(3,1) ...
        combinedError(4,1) combinedError(5,1) combinedError(6,1) ...
        combinedError(7,1) combinedError(8,1) combinedError(9,1)]);
    hold on
    bar([combinedError(1,2) combinedError(2,2) combinedError(3,2) ...
        combinedError(4,2) combinedError(5,2) combinedError(6,2) ...
        combinedError(7,2) combinedError(8,2) combinedError(9,2)],.25,'r');
    
    set(gca, 'XTickLabel', {'sp','le','ld','ld2','lcl','ap','qol','im', ...
        'st'});
    legend('MEAN RMSD','STD RMSD');
    set(0, 'currentfigure', f);
    hold off
    box off
end

