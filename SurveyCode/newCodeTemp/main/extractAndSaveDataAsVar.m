%Ryan Brummet
%University of Iowa

%This function does little besides call other functions.  The net result of
%calling this function is to extract and remove non-relevant data from the
%input data file and save the results as a variable.  Notice that some
%function calls may return variables that are not used or needed.  This is
%becaouse the manner in which several functions have beend used has changed
%over time.

%extractedData will be in the form Patient, listening, userInit, ac, lc,
%tf, vc, tl, nl, rs, cp, nz, condition, sp, le, ld, ld2, lcl, ap, qol, im, 
%st

function [ ] = extractAndSaveDataAsVar( targetFileName, ...
    removeFifties, omitNotListening, omitListening, omitNotUserInit,...
    omitUserInit, normalization, trim)

    %targetFileName (string): self explanatory
    
    %removeFifties (bool):    true if fifty values before Jan 30, 2014 
    %                         should be removed. false otherwise
    
    %omitNotListening (bool): true if samples where the user is not
    %                         listening should be removed. false otherwise
    
    %omitListening (bool):    true if samples where the user is listening
    %                         should be removed. false otherwise
    
    %omitNotUserInit (bool):  true if samples where the user did not
    %                         initiate the survey should be removed. false 
    %                         otherwise
    
    %omitUserInit (bool):     true if samples where the user initiated the
    %                         survey should be removed. false otherwise
    
    %normalization (int):     0 for no normalization, 1 for global
    %                         normalization, 2 for user normalization
    
    
    [data, userSet] = extractAndProcData(targetFileName, true, false, ...
        false, false, false);
    
    [extractedData, userSampleCount, userIndexSet] = ...
        testSurveyDuration( data, 50, userSet);
    
    [extractedData, userSet, userSampleCount, userIndexSet] = ...
        removeNonQualUsers(extractedData, userSet, userSampleCount, ...
        userIndexSet);
    
    if normalization == 1
        [extractedData] = normalizeDataGlobally(extractedData);
    elseif normalization == 2
        [extractedData] = normalizeAcrossUsers(extractedData, ...
            userSet);
    else
       if normalization ~= 0
           error('The normalization value must be 0, 1, or 2'); 
       end
    end
    
    if trim > 0
        [trimmedData] = trimData(extractedData,trim);
    end
    
    if normalization == 0
        save('rawData','extractedData','trimmedData');
    elseif normalization == 1
        save('globalNormData','extractedData','trimmedData');
    else
        save('userNormData','extractedData','trimmedData'); 
    end
end

