%Author Ryan Brummet
%University of Iowa

function [ Results ] = findRMSOfAllPossibleMappings( targetFileName, repeat)

%targetFileName (input string): raw input data file name. include the
%       extension.

%repeat (input int): gives the number of times to repeat mapping evaluation
%       for a given setting.



    %we repeat the experiment repeat times to account for variability that may
    %arise becuase of random number generation.  RMSVals stored in the form
    %normalizationValUsed, mapByUser, stratifySampling, reSample,
    %attrMapTarget, polyFitDeg, meanIndvMinRMS, meanIndvMaxRMS,
    %meanIndvMeanRMS, meanIndvMedianRMS, meanIndvSTDRMS, meanCombMeanRMS,
    %meanCombMedianRMS
    
    %extract the data
    [Data, userSet] = extractAndProcData(targetFileName, ...
        true, false, false, false, ...
        false);

    for run = 1 : repeat
        index = 1;
        for normal = 0 : 2
            for userMap = 0 : 0  %we have found that we don't have enough data to map by user
                for stratify = 0 : 1
                    for reSample = 0 : 1
                        for target = 1 : 9
                                
                            %if target == 6
                             %   continue;
                            %end
                            for deg = 5 : 5
                                index + run * .1
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
                                    
                                [RMSTemp] = ...
                                    mapAttributes(userMap, stratify, reSample, ...
                                    attrMapTarget, deg, extractedData, ...
                                    userSampleCount, userIndexSet);
                            
                                Results(index,1,run) = normal;
                                Results(index,2,run) = userMap;
                                Results(index,3,run) = stratify;
                                Results(index,4,run) = reSample;
                                Results(index,5,run) = target;
                                Results(index,6,run) = deg;
                                for k = 1 : size(RMSTemp,2)
                                    Results(index,6 + k, run) = RMSTemp(k);
                                end
                                index = index + 1;
                            end
                        end
                    end
                end
            end
        end
    end

    Results = nanmean(Results,3);
end


