    %Author Ryan Brummet
%University of Iowa

function [ RMSVals ] = findRMSOfAllPossibleMappings( targetFileName, repeat)

%targetFileName (input string): raw input data file name. include the
%       extension.

%repeat (input int): gives the number of times to repeat mapping evaluation
%       for a given setting.

%RMSVals (input matrix): gives the normalized root mean squared error of
%       various mappings.  This matrix is in the form normal, userMap,
%       stratify, sample, target, deg, minSingleRMS, maxSingleRMS,
%       meanSingleRMS, medianSingleRMS, std, meanCRMS, medianCRMS


    %we repeat the experiment repeat times to account for variability that may
    %arise becuase of random number generation.  RMSVals stored in the form
    %normalizationValUsed, mapByUser, stratifySampling, reSample,
    %attrMapTarget, polyFitDeg, meanMedianAttrCombine, RMS score.
    RMSValsTemp = zeros(1,13,repeat);
    
    %extract the data
    [Data, userSet] = extractAndProcData(targetFileName, ...
        true, false, false, false, ...
        false);
    
    for run = 1 : repeat
        index = 1;
        for normal = 0 : 2
            for userMap = 0 : 1
                for stratify = 0 : 1
                    for sample = 0 : 1
                        for target = 1 : 9
                            
                            %this must be commented out to run for all 9
                            %attr; see line 97
                            for deg = 1 : 5
                                
                                index + run *.1
                                userSetTemp = userSet;
                                %remove attributes that are not needed
                                [ extractedData, attrMapTarget ] = pickAttrs( Data, [1,1,1,1,1,1,1,1,1], target);
    
                                %remove samples that don't make duration requirements
                                [extractedData, userSampleCount, userIndexSet] = testSurveyDuration( ...
                                    extractedData, 50, userSetTemp);
    
                                %remove all samples of users that don't have at least 20 samples
                                %this is done to prevent problems that may arise because of a small
                                %sample set when normalizing or mapping attributes
                                [extractedData, userSetTemp, userSampleCount, userIndexSet] = ...
                                    removeNonQualUsers(extractedData, userSetTemp, userSampleCount, ...
                                    userIndexSet);
    
                                %normalize based on normalizeMathod (or don't normalize)
                                if normal == 1
                                    [extractedData] = normalizeDataGlobally(extractedData);
                                elseif normal == 2
                                    [extractedData] = normalizeAcrossUsers(extractedData, ...
                                        userSetTemp);
                                end
                                    
                                [mappedData, mappingCoefficients] = ...
                                    mapAttributes(userMap, stratify, sample, ...
                                    attrMapTarget, deg, extractedData, ...
                                    userSampleCount, userIndexSet);
                            
                                RMSValsTemp(index,1,run) = normal;
                                RMSValsTemp(index,2,run) = userMap;
                                RMSValsTemp(index,3,run) = stratify;
                                RMSValsTemp(index,4,run) = sample;
                                RMSValsTemp(index,5,run) = target;
                                RMSValsTemp(index,6,run) = deg;
                                indvRMS = zeros(1,size(mappedData,2) - 13);
                                for attr = 1 : size(mappedData,2) - 13
                                    summation = 0;
                                    amount = 0;
                                    maximum = 0;
                                    minimum = 0;
                                    for k = 1 : size(mappedData,1)
                                        if mappedData(k,13 + attr) >= 0 && extractedData(k,13 + attr) >= 0
                                            summation = summation + (mappedData(k,13 + attr) - extractedData(k, 13 + attr))^2;
                                            amount = amount + 1;
                                            if minimum > mappedData(k,13 + attr)
                                                minimum = mappedData(k,13 + attr); 
                                            elseif maximum < mappedData(k,13 + attr)
                                                maximum = mappedData(k,13 + attr);
                                            end
                                        end
                                    end
                                    indvRMS(attr) = sqrt(summation / amount) / (maximum - minimum);
                                end
                                RMSValsTemp(index,7,run) = min(indvRMS);
                                RMSValsTemp(index,8,run) = max(indvRMS);
                                RMSValsTemp(index,9,run) = mean(indvRMS);
                                RMSValsTemp(index,10,run) = median(indvRMS);
                                RMSValsTemp(index,11,run) = std(indvRMS);
                                    
                                for j = 0 : 1
                                    summation = 0;
                                    minimum = 100;
                                    maximum = 0;
                                    amount = 0;
                                    [combinedData] = combineScoresAndReScale(mappedData,j);
                                    for k = 1 : size(extractedData,1)
                                        if extractedData(k,13 + attrMapTarget) >= 0 && combinedData(k,14) >= 0
                                            summation = summation + (extractedData(k,13 + attrMapTarget) - combinedData(k,14))^2; 
                                            amount = amount + 1;
                                            if minimum > combinedData(k,14)
                                                minimum = combinedData(k,14); 
                                            elseif maximum < combinedData(k,14)
                                                maximum = combinedData(k,14); 
                                            end
                                        end
                                    end
                                    RMSValsTemp(index,12 + j,run) = (sqrt(summation / amount)) / (maximum - minimum);
                                    clearvars combinedData;
                                end
                                    
                                index = index + 1;
                                clearvars summation minimum maximum amount extractedData attrMapTarget ...
                                    userSampleCount userIndexSet userSetTemp userSampleCount ... 
                                    mappedData mappingError mappingCoefficients attr indvRMS j k
                            end
                        end
                    end
                end
            end
        end
    end


    RMSVals = zeros(1,13);
    for k = 1 : size(RMSValsTemp,1)
        for j = 1 : 6
            RMSVals(k,j) = RMSValsTemp(k,j,1);
        end
        RMSVals(k,7) = mean(RMSValsTemp(k,7,1:repeat));
        RMSVals(k,8) = mean(RMSValsTemp(k,8,1:repeat));
        RMSVals(k,9) = mean(RMSValsTemp(k,9,1:repeat));
        RMSVals(k,10) = mean(RMSValsTemp(k,10,1:repeat));
        RMSVals(k,11) = mean(RMSValsTemp(k,11,1:repeat));
        RMSVals(k,12) = mean(RMSValsTemp(k,12,1:repeat));
        RMSVals(k,13) = mean(RMSValsTemp(k,13,1:repeat));
    end
    save('RMSValsAllReal.mat','RMSVals');
end

