%Ryan Brummet
%University of Iowa

function [ ] = distBeforeAndAfterFiftiesRemoved( targetFileName, ...
    removeFifties,omitNotListening, omitListening, omitNotUserInit, ...
    omitUserInit )

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
        if strcmp(charArray(1,28),'true') && tempBool
            
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
                    returnedData(index,24) = startTimeYear;
                    returnedData(index,25) = startTimeMonth;
                    returnedData(index,26) = startTimeDay;
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
                    returnedData(index,24) = startTimeYear;
                    returnedData(index,25) = startTimeMonth;
                    returnedData(index,26) = startTimeDay;
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
    
    beforeIndex = 1;
    afterIndex = 1;
    for k = 1 : size(returnedData,1)
        if getUnixTime(2014,1,30,0,0,0) >= getUnixTime(returnedData(k,24), ...
                returnedData(k,25),returnedData(k,26),0,0,0);
            beforeData(beforeIndex,:) = returnedData(k,:);
            beforeIndex = beforeIndex + 1;
        else
            afterData(afterIndex,:) = returnedData(k,:);
            afterIndex = afterIndex + 1;
        end
    end
    
    labels{1} = 'sp';
    labels{2} = 'le';
    labels{3} = 'ld';
    labels{4} = 'ld2';
    labels{5} = 'lcl';
    labels{6} = 'ap';
    labels{7} = 'qol';
    labels{8} = 'im';
    labels{9} = 'st';

    figure(1);
    for k = 1 : 9
       subplot(3,3,k);
       hist(beforeData(:,13 + k),100);
       title(strcat('Distribution of', {' '},labels{k},{' '},'Before 50 Removal'));
       xlabel('Attribute Value');
       ylabel('Amount');
    end
    
    figure(2);
    for k = 1 : 9
       subplot(3,3,k);
       hist(afterData(:,13 + k),100);
       title(strcat('Distribution of', {' '},labels{k},{' '},'After 50 Removal'));
       xlabel('Attribute Value');
       ylabel('Amount');
    end
    
    temp = beforeData == 50;
    beforeData(temp) = NaN;
    figure(3)
    for k = 1 : 9
        subplot(3,3,k);
        hist(beforeData(:,13 + k), 100);
        title(strcat('Distribution of', {' '}, labels{k},{' '}, 'Before Wt out 50'));
        xlabel('Attribute Value');
        ylabel('Amount');
    end
    
%     figure(4)
%     for k = 1 : 9
%         subplot(3,3,k);
%         hist(beforeData(:,13 + k),100);
%         hold on
%         hist(afterData(:,13 + k),100);
%         hold off
%         h = findobj(gca,'Type','patch');
%         set(h(1),'FaceColor','r','EdgeColor','k');
%         set(h(2),'FaceColor','g','EdgeColor','b');
%         
%         title(strcat('Before and After Dist without 50s for', {' '}, ...
%             labels{k}));
%         xlabel('Attribute Value');
%         ylabel('Amount');
%         
%     end
    
    figure(5)
    for k = 1 : 9
        subplot(3,3,k);
        clearvars beforeAmount afterAmount beforeTemp afterTemp ...
            beforePlot afterPlot
        beforeAmount = sum(~isnan(beforeData(:,13 + k)));
        beforeTemp = beforeData(~isnan(beforeData(:,13 + k)),13 + k);
        
        afterAmount = sum(~isnan(afterData(:,13 +k)));
        afterTemp = afterData(~isnan(afterData(:, 13 + k)),13 + k);
        for j = 1 : 100
            beforePlot(1,j) = sum(beforeTemp == j) / beforeAmount;
            afterPlot(1,j) = sum(afterTemp == j) / afterAmount;
        end
        
        
        plot(1:100, beforePlot * 100, 'r-')
        hold on
        plot(1:100, afterPlot * 100, 'b-')
%         bar(beforePlot,'g');
%         hold on
%         bar(afterPlot,.25,'r');
%         hold off
    end
    
end

