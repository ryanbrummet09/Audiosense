%Author Ryan Brummet
%University of Iowa

function [ returnedData, userSet ] = extractAndProcData( targetFileName, ...
    removeFifties, omitNotListening, omitListening, omitNotUserInit, ...
    omitUserInit)
%Extracts patient Data and returns the info in an array.  Also records all
%the user id's in the extracted data set.

%The input file must be of the form patient, condition, session, survey, 
%starttime, endtime, appwelcome, listening, duration, subjectbash, 
%subjectwelcome, acSpeech, %ac1, location, lc1, tf1, vc1, tl1, nz1, nl1, 
%rs1, cp1, sp, le1, ld, ld2, %lcl, hau, hapq, st, ap, qol, im, 
%userinitiated

%Returned data will be in the form Patient, listening, userInit, ac, lc,
%tf, vc, tl, nl, rs, cp, nz, condition, sp, le, ld, ld2, lcl, ap, qol, im, 
%st

%data that is deemed bad, ie 50 values, insufficient survey taking time,
%are not extracted.  Instead either NaN values are inserted or the sample
%is discarded.  50 values may optionally be removed and the time a person
%must spend taking a survey may be adjusted.  In particular, all surveys
%must be with the given percentage of the average amount of time that a
%person spends taking a survey.

%  targetFileName (input string): name of data file

%  removeFifties  (input bool): whether or not to remove 50 values

%  omitNotListening (input bool): whether or not to include samples where
%       users were not listening

%  omitListenging (input bool): whether or not to include samples where
%       users were listening

%  omitNotUserInit (input bool): whether or not to include survey samples
%       that were not initiated by users

%  omitUserInit (input bool): whether or not to include survey samples that
%       were initiated by users

%  returnedData (output matrix): the extractedData

%  userSet (output vector): gives a vector of all user id's

    fid = fopen(targetFileName);

    %remove column names
    fgetl(fid);

    charArray = fgetl(fid);
    index = 1;
    tempIndexes = [23, 24, 25, 26, 27, 31, 32, 33, 30];
    returnedData = zeros(1,23);
    userIndex = 1;
    userSet = zeros(1,1);
    
    %extract data
    while(ischar(charArray))
        tempBool = true;
        clearvars temp;
        charArray = strsplit(charArray, ',');
    
        %omit samples from extractedData based on desired attributes
        if omitNotListening || omitListening || omitNotUserInit || omitUserInit
            if omitNotListening && str2double(charArray(1,8)) == 0
                tempBool = false; 
            end
            if omitListening && str2double(charArray(1,8)) == 1
                tempBool = false;  
            end
            if omitNotUserInit && str2double(charArray(1,34)) == 0
                tempBool = false;  
            end
            if omitUserInit && str2double(charArray(1,34)) == 1
                tempBool = false;  
            end
        end
    
        %find how long it took user to take survey
        startTime = cell2mat(charArray(1,5));
        endTime = cell2mat(charArray(1,6));
        
        startTimeYear = (str2double(startTime(1,1))*1000) + (str2double(startTime(1,2))*100) + (str2double(startTime(1,3))*10) + (str2double(startTime(1,4)));
        startTimeMonth = (str2double(startTime(1,6))*10) + (str2double(startTime(1,7)));
        startTimeDay = (str2double(startTime(1,9))*10) + (str2double(startTime(1,10)));
        startTimeHour = (str2double(startTime(1,12))*10) + str2double(startTime(1,13));
        startTimeMin = (str2double(startTime(1,15))*10) + str2double(startTime(1,16));
        startTimeSec = (str2double(startTime(1,18))*10) + str2double(startTime(1,19));
        
        endTimeHour = (str2double(endTime(1,12))*10) + str2double(endTime(1,13));
        endTimeMin = (str2double(endTime(1,15))*10) + str2double(endTime(1,16));
        endTimeSec = (str2double(endTime(1,18))*10) + str2double(endTime(1,19));
        
        duration = ((endTimeHour - startTimeHour) * 3600) + ((endTimeMin - startTimeMin) * 60) + endTimeSec - startTimeSec;

        %check if a person was wearing a hearing aid
        if str2double(charArray(1,28)) == 1 && tempBool
            
            %finds fifty values. moves to next sample if removeFifties is
            %true and after replacing all fifties with NaN all attributes
            %are NaN
            temp = zeros(1,9);
            for k = 1 : 9
                if str2double(charArray(1,tempIndexes(k))) ~= 50 || getUnixTime(startTimeYear, startTimeMonth, startTimeDay,0,0,0) > getUnixTime(2014,1,30,0,0,0)
                    temp(1,k) = str2double(charArray(1,tempIndexes(k)));
                else
                    temp(1,k) = NaN;
                end
            end
            if size(find(isnan(temp)),2) == 9 && removeFifties
                charArray = fgetl(fid);
                continue;
            end
            
            temp2 = cell2mat(charArray(1,1));
            temp2 = (str2double(temp2(1,4))*10) + str2double(temp2(1,5));
        
            %record every user id so that we know how many users there are
            if ~ismember(temp2,userSet)
                userSet(1,userIndex) = temp2;
                userIndex = userIndex + 1;
            end
        
            %samples that have no usable attribute data are excluded from
            %extractedData
            if ((str2double(charArray(1,23)) >= 0) || (str2double(charArray(1,24)) >= 0) ...
                || (str2double(charArray(1,25)) >= 0) || (str2double(charArray(1,26)) >= 0) ...
                || (str2double(charArray(1,27)) >= 0) || (str2double(charArray(1,31)) >= 0) ...
                || (str2double(charArray(1,32)) >= 0) || (str2double(charArray(1,33)) >= 0) ...
                || (str2double(charArray(1,30)) >= 0))
           
                returnedData(index,1) = temp2;
                returnedData(index,2) = str2double(charArray(1,8));
                returnedData(index,3) = str2double(charArray(1,34));
                returnedData(index,4) = str2double(charArray(1,13));
                returnedData(index,5) = str2double(charArray(1,15));
                returnedData(index,6) = str2double(charArray(1,16));
                returnedData(index,7) = str2double(charArray(1,17));
                returnedData(index,8) = str2double(charArray(1,18));
                returnedData(index,9) = str2double(charArray(1,20));
                returnedData(index,10) = str2double(charArray(1,21));
                returnedData(index,11) = str2double(charArray(1,22));
                returnedData(index,12) = str2double(charArray(1,19));
                returnedData(index,13) = str2double(charArray(1,2));
        
                %if removeFiftyVals is true replace 50 values with NaN else
                %continue normally
                if removeFifties
                    returnedData(index,14:22) = temp;
                    returnedData(index,23) = duration;
                else
                    returnedData(index,14) = str2double(charArray(1,23));
                    returnedData(index,15) = str2double(charArray(1,24));
                    returnedData(index,16) = str2double(charArray(1,25));
                    returnedData(index,17) = str2double(charArray(1,26));
                    returnedData(index,18) = str2double(charArray(1,27));
                    returnedData(index,19) = str2double(charArray(1,31));
                    returnedData(index,20) = str2double(charArray(1,32));
                    returnedData(index,21) = str2double(charArray(1,33));
                    returnedData(index,22) = str2double(charArray(1,30));
                    returnedData(index,23) = duration;
                end
                index = index + 1;
            end
        end
        charArray = fgetl(fid);
    end
    fclose(fid);
    %prevents the function from continuing if extractedData is empty.  This
    %could happen because of user error when addiing params to the function
    %call
    if size(returnedData,1) < 2
        error('extractedData contains zero samples.  Check your function input');
    end
end

