%Ryan Brummet
%University of Iowa

function [ ] = processData( rawData )
    %rawData (input matrix): data output by findRMSOfAllPossibleMappings
        %this is in the form normal, usermap, stratify, reSample, target,
        %deg, spRMS, spMeanPartRMS, leRMS, leMeanPartRMS, ldRMS,
        %ldMeanRMS, ld2RMS, ld2MeanRMS, lclRMS, lclMeanRMS, apRMS,
        %apMeanRMS, qolRMS, qolMeanRMS, imRMS, imMeanRMS, stRMS,
        %stMeanRMS
    
    %findings (output vector): gives the optimal mapping settings
    
    
    %we first want to find the optimal settings for normall, usermap,
    %stratify, reSample, target, and deg.  We do this by looking at the 
    %whole data set and spliting it up into groups for each setting where 
    %the number of groups equals the number of possibilities for each 
    %setting.  For each group we sum up the RMSDNorm values (including for 
    %each target) for both the actual and partition mean.  Since we are 
    %taking a brute force approach, any differences that appear must be 
    %becuase of differences caused by the single setting being analyzed.
    
    %----------analyze normal---------
    index0 = 1;
    index1 = 1;
    index2 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,1) == 0
            group0(index0,:) = rawData(k,:); 
            index0 = index0 + 1;
        elseif rawData(k,1) == 1
            group1(index1,:) = rawData(k,:);
            index1 = index1 + 1;
        else
            group2(index2,:) = rawData(k,:);
            index2 = index2 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group0,1)
        sum0 = sum0 + group0(k,7) + group0(k,9) + group0(k,11) + ...
            group0(k,13) + group0(k,15) + group0(k,17) + group0(k,19) + ...
            group0(k,21) + group0(k,23);
        sum1 = sum1 + group0(k,8) + group0(k,10) + group0(k,12) + ...
            group0(k,14) + group0(k,16) + group0(k,18) + group0(k,20) + ...
            group0(k,22) + group0(k,24);
    end
    normal(1,1) = sum0;
    normal(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    normal(2,1) = sum0;
    normal(2,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group2,1)
        sum0 = sum0 + group2(k,7) + group2(k,9) + group2(k,11) + ...
            group2(k,13) + group2(k,15) + group2(k,17) + group2(k,19) + ...
            group2(k,21) + group2(k,23);
        sum1 = sum1 + group2(k,8) + group2(k,10) + group2(k,12) + ...
            group2(k,14) + group2(k,16) + group2(k,18) + group2(k,20) + ...
            group2(k,22) + group2(k,24);
    end
    normal(3,1) = sum0;
    normal(3,2) = sum1;
    
    clearvars group0 group1 group2 index0 index1 index2 sum0 sum1
    
    %----------analyze usermap----------
    index0 = 1;
    index1 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,2) == 0
            group0(index0,:) = rawData(k,:); 
            index0 = index0 + 1;
        else
            group1(index1,:) = rawData(k,:);
            index1 = index1 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group0,1)
        sum0 = sum0 + group0(k,7) + group0(k,9) + group0(k,11) + ...
            group0(k,13) + group0(k,15) + group0(k,17) + group0(k,19) + ...
            group0(k,21) + group0(k,23);
        sum1 = sum1 + group0(k,8) + group0(k,10) + group0(k,12) + ...
            group0(k,14) + group0(k,16) + group0(k,18) + group0(k,20) + ...
            group0(k,22) + group0(k,24);
    end
    usermap(1,1) = sum0;
    usermap(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    usermap(2,1) = sum0;
    usermap(2,2) = sum1;
    
    clearvars group0 group1 index0 index1 sum0 sum1
    
    %----------analyze stratify----------
    index0 = 1;
    index1 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,3) == 0
            group0(index0,:) = rawData(k,:); 
            index0 = index0 + 1;
        else
            group1(index1,:) = rawData(k,:);
            index1 = index1 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group0,1)
        sum0 = sum0 + group0(k,7) + group0(k,9) + group0(k,11) + ...
            group0(k,13) + group0(k,15) + group0(k,17) + group0(k,19) + ...
            group0(k,21) + group0(k,23);
        sum1 = sum1 + group0(k,8) + group0(k,10) + group0(k,12) + ...
            group0(k,14) + group0(k,16) + group0(k,18) + group0(k,20) + ...
            group0(k,22) + group0(k,24);
    end
    stratify(1,1) = sum0;
    stratify(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    stratify(2,1) = sum0;
    stratify(2,2) = sum1;
    
    clearvars group0 group1 index0 index1 sum0 sum1
    
    %----------analyze reSample----------
    index0 = 1;
    index1 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,4) == 0
            group0(index0,:) = rawData(k,:); 
            index0 = index0 + 1;
        else
            group1(index1,:) = rawData(k,:);
            index1 = index1 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group0,1)
        sum0 = sum0 + group0(k,7) + group0(k,9) + group0(k,11) + ...
            group0(k,13) + group0(k,15) + group0(k,17) + group0(k,19) + ...
            group0(k,21) + group0(k,23);
        sum1 = sum1 + group0(k,8) + group0(k,10) + group0(k,12) + ...
            group0(k,14) + group0(k,16) + group0(k,18) + group0(k,20) + ...
            group0(k,22) + group0(k,24);
    end
    reSample(1,1) = sum0;
    reSample(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    reSample(2,1) = sum0;
    reSample(2,2) = sum1;
    
    clearvars group0 group1 index0 index1 sum0 sum1
    
    %----------analyze target----------
    index1 = 1;
    index2 = 1;
    index3 = 1;
    index4 = 1;
    index5 = 1;
    index6 = 1;
    index7 = 1;
    index8 = 1;
    index9 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,5) == 1
            group1(index1,:) = rawData(k,:); 
            index1 = index1 + 1;
        elseif rawData(k,5) == 2
            group2(index2,:) = rawData(k,:);
            index2 = index2 + 1;
        elseif rawData(k,5) == 3
            group3(index3,:) = rawData(k,:);
            index3 = index3 + 1;
        elseif rawData(k,5) == 4
            group4(index4,:) = rawData(k,:);
            index4 = index4 + 1;
        elseif rawData(k,5) == 5
            group5(index5,:) = rawData(k,:);
            index5 = index5 + 1;
        elseif rawData(k,5) == 6
            group6(index6,:) = rawData(k,:);
            index6 = index6 + 1;
        elseif rawData(k,5) == 7
            group7(index7,:) = rawData(k,:);
            index7 = index7 + 1;
        elseif rawData(k,5) == 8
            group8(index8,:) = rawData(k,:);
            index8 = index8 + 1;
        else
            group9(index9,:) = rawData(k,:);
            index9 = index9 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    target(1,1) = sum0;
    target(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group2,1)
        sum0 = sum0 + group2(k,7) + group2(k,9) + group2(k,11) + ...
            group2(k,13) + group2(k,15) + group2(k,17) + group2(k,19) + ...
            group2(k,21) + group2(k,23);
        sum1 = sum1 + group2(k,8) + group2(k,10) + group2(k,12) + ...
            group2(k,14) + group2(k,16) + group2(k,18) + group2(k,20) + ...
            group2(k,22) + group2(k,24);
    end
    target(2,1) = sum0;
    target(2,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group3,1)
        sum0 = sum0 + group3(k,7) + group3(k,9) + group3(k,11) + ...
            group3(k,13) + group3(k,15) + group3(k,17) + group3(k,19) + ...
            group3(k,21) + group3(k,23);
        sum1 = sum1 + group3(k,8) + group3(k,10) + group3(k,12) + ...
            group3(k,14) + group3(k,16) + group3(k,18) + group3(k,20) + ...
            group3(k,22) + group3(k,24);
    end
    target(3,1) = sum0;
    target(3,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group4,1)
        sum0 = sum0 + group4(k,7) + group4(k,9) + group4(k,11) + ...
            group4(k,13) + group4(k,15) + group4(k,17) + group4(k,19) + ...
            group4(k,21) + group4(k,23);
        sum1 = sum1 + group4(k,8) + group4(k,10) + group4(k,12) + ...
            group4(k,14) + group4(k,16) + group4(k,18) + group4(k,20) + ...
            group4(k,22) + group4(k,24);
    end
    target(4,1) = sum0;
    target(4,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group5,1)
        sum0 = sum0 + group5(k,7) + group5(k,9) + group5(k,11) + ...
            group5(k,13) + group5(k,15) + group5(k,17) + group5(k,19) + ...
            group5(k,21) + group5(k,23);
        sum1 = sum1 + group5(k,8) + group5(k,10) + group5(k,12) + ...
            group5(k,14) + group5(k,16) + group5(k,18) + group5(k,20) + ...
            group5(k,22) + group5(k,24);
    end
    target(5,1) = sum0;
    target(5,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group6,1)
        sum0 = sum0 + group6(k,7) + group6(k,9) + group6(k,11) + ...
            group6(k,13) + group6(k,15) + group6(k,17) + group6(k,19) + ...
            group6(k,21) + group6(k,23);
        sum1 = sum1 + group6(k,8) + group6(k,10) + group6(k,12) + ...
            group6(k,14) + group6(k,16) + group6(k,18) + group6(k,20) + ...
            group6(k,22) + group6(k,24);
    end
    target(6,1) = sum0;
    target(6,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group7,1)
        sum0 = sum0 + group7(k,7) + group7(k,9) + group7(k,11) + ...
            group7(k,13) + group7(k,15) + group7(k,17) + group7(k,19) + ...
            group7(k,21) + group7(k,23);
        sum1 = sum1 + group7(k,8) + group7(k,10) + group7(k,12) + ...
            group7(k,14) + group7(k,16) + group7(k,18) + group7(k,20) + ...
            group7(k,22) + group7(k,24);
    end
    target(7,1) = sum0;
    target(7,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group8,1)
        sum0 = sum0 + group8(k,7) + group8(k,9) + group8(k,11) + ...
            group8(k,13) + group8(k,15) + group8(k,17) + group8(k,19) + ...
            group8(k,21) + group8(k,23);
        sum1 = sum1 + group8(k,8) + group8(k,10) + group8(k,12) + ...
            group8(k,14) + group8(k,16) + group8(k,18) + group8(k,20) + ...
            group8(k,22) + group8(k,24);
    end
    target(8,1) = sum0;
    target(8,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group9,1)
        sum0 = sum0 + group9(k,7) + group9(k,9) + group9(k,11) + ...
            group9(k,13) + group9(k,15) + group9(k,17) + group9(k,19) + ...
            group9(k,21) + group9(k,23);
        sum1 = sum1 + group9(k,8) + group9(k,10) + group9(k,12) + ...
            group9(k,14) + group9(k,16) + group9(k,18) + group9(k,20) + ...
            group9(k,22) + group9(k,24);
    end
    target(9,1) = sum0;
    target(9,2) = sum1;
    
    clearvars group1 group2 group3 group4 group5 group6 group7 group8 ...
        group9 index1 index2 index3 index4 index5 index6 index7 index8 ...
        index9 sum0 sum1
    
    %----------analyze deg----------
    index1 = 1;
    index2 = 1;
    index3 = 1;
    index4 = 1;
    index5 = 1;
    %make groups
    for k = 1 : size(rawData,1)
        if rawData(k,6) == 1
            group1(index1,:) = rawData(k,:); 
            index1 = index1 + 1;
        elseif rawData(k,6) == 2
            group2(index2,:) = rawData(k,:);
            index2 = index2 + 1;
        elseif rawData(k,6) == 3
            group3(index3,:) = rawData(k,:);
            index3 = index3 + 1;
        elseif rawData(k,6) == 4
            group4(index4,:) = rawData(k,:);
            index4 = index4 + 1;
        else
            group5(index5,:) = rawData(k,:);
            index5 = index5 + 1;
        end
    end
    %find sum of RMSDNorm for actual and partition mean of each group
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group1,1)
        sum0 = sum0 + group1(k,7) + group1(k,9) + group1(k,11) + ...
            group1(k,13) + group1(k,15) + group1(k,17) + group1(k,19) + ...
            group1(k,21) + group1(k,23);
        sum1 = sum1 + group1(k,8) + group1(k,10) + group1(k,12) + ...
            group1(k,14) + group1(k,16) + group1(k,18) + group1(k,20) + ...
            group1(k,22) + group1(k,24);
    end
    deg(1,1) = sum0;
    deg(1,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group2,1)
        sum0 = sum0 + group2(k,7) + group2(k,9) + group2(k,11) + ...
            group2(k,13) + group2(k,15) + group2(k,17) + group2(k,19) + ...
            group2(k,21) + group2(k,23);
        sum1 = sum1 + group2(k,8) + group2(k,10) + group2(k,12) + ...
            group2(k,14) + group2(k,16) + group2(k,18) + group2(k,20) + ...
            group2(k,22) + group2(k,24);
    end
    deg(2,1) = sum0;
    deg(2,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group3,1)
        sum0 = sum0 + group3(k,7) + group3(k,9) + group3(k,11) + ...
            group3(k,13) + group3(k,15) + group3(k,17) + group3(k,19) + ...
            group3(k,21) + group3(k,23);
        sum1 = sum1 + group3(k,8) + group3(k,10) + group3(k,12) + ...
            group3(k,14) + group3(k,16) + group3(k,18) + group3(k,20) + ...
            group3(k,22) + group3(k,24);
    end
    deg(3,1) = sum0;
    deg(3,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group4,1)
        sum0 = sum0 + group4(k,7) + group4(k,9) + group4(k,11) + ...
            group4(k,13) + group4(k,15) + group4(k,17) + group4(k,19) + ...
            group4(k,21) + group4(k,23);
        sum1 = sum1 + group4(k,8) + group4(k,10) + group4(k,12) + ...
            group4(k,14) + group4(k,16) + group4(k,18) + group4(k,20) + ...
            group4(k,22) + group4(k,24);
    end
    deg(4,1) = sum0;
    deg(4,2) = sum1;
    
    sum0 = 0;
    sum1 = 0;
    for k = 1 : size(group5,1)
        sum0 = sum0 + group5(k,7) + group5(k,9) + group5(k,11) + ...
            group5(k,13) + group5(k,15) + group5(k,17) + group5(k,19) + ...
            group5(k,21) + group5(k,23);
        sum1 = sum1 + group5(k,8) + group5(k,10) + group5(k,12) + ...
            group5(k,14) + group5(k,16) + group5(k,18) + group5(k,20) + ...
            group5(k,22) + group5(k,24);
    end
    deg(5,1) = sum0;
    deg(5,2) = sum1;
    
    clearvars group1 group2 group3 group4 group5 index1 index2 index3 ...
        index4 index5 sum0 sum1
    
    %----------create data plot----------
    figure;
    
    subplot(3,2,1);
    x = [0,1,2];
    bar(x,normal(:,1),.5,'r');
    hold on
    bar(x,normal(:,2),.3,'c');
    hold off
    title('normal Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
    subplot(3,2,2);
    x = [0,1];
    bar(x,usermap(:,1),.5,'r');
    hold on
    bar(x,usermap(:,2),.3,'c');
    hold off
    title('usermap Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
    subplot(3,2,3);
    x = [0,1];
    bar(x,stratify(:,1),.5,'r');
    hold on
    bar(x,stratify(:,2),.3,'c');
    hold off
    title('stratify Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
    subplot(3,2,4);
    x = [0,1];
    bar(x,reSample(:,1),.5,'r');
    hold on
    bar(x,reSample(:,2),.3,'c');
    hold off
    title('reSample Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
    subplot(3,2,5);
    x = [1,2,3,4,5,6,7,8,9];
    bar(x,target(:,1),.5,'r');
    hold on
    bar(x,target(:,2),.3,'c');
    hold off
    title('target Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
    subplot(3,2,6);
    x = [1,2,3,4,5];
    bar(x,deg(:,1),.5,'r');
    hold on
    bar(x,deg(:,2),.3,'c');
    hold off
    title('deg Settings');
    ylabel('Sum RMSDNorm Values');
    xlabel('Setting Value');
    %legend('Actual RMSDNorm','Cross Validation Partition Mean RMSDNorm');
    
end



