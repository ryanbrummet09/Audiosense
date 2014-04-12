%we will use the following attribute designation. ac = 10, lc = 20, tf =
%30, vc = 40, tl = 50, nl = 60, rs = 70, cp = 80, nz = 90.  Furthermore we
%will describe each attribute type by its number.  In other words ac7 = 17,
%nz1 = 91, and nl4 = 64.

%attribute maximums. bound becuase for all a, a on [1,max].  I have listed
%these values only for programmer clarification (I could have just coded
%the numbers)
acbound = 7; %21 combinations
lcbound = 5; %10
tfbound = 4; %6
vcbound = 3; %3
tlbound = 3; %3
nlbound = 4; %6
rsbound = 3; %3
cpbound = 2; %1
nzbound = 4; %6

boundArray = [acbound, lcbound, tfbound, vcbound, tlbound, nlbound, rsbound, cpbound, nzbound];

targetGroupIndex = 1;
remainingGroupIndex = 1;
pIndex = 1;
insufficientIndex = 1;
for targetAttribute = 1 : 9
    disp(targetAttribute);
    for lowerBound = 1 : boundArray(targetAttribute)
        for k = 1 : size(extractedData,1)
            if extractedData(k,3 + targetAttribute) == lowerBound
                targetGroup(targetGroupIndex,:) = extractedData(k,:);
                targetGroupIndex = targetGroupIndex + 1;
            else
                remainingGroup(remainingGroupIndex,:) = extractedData(k,:);
                remainingGroupIndex = remainingGroupIndex + 1;
            end
        end
        if size(targetGroup,1) < 50
           insufficientContexts(insufficientIndex) = 10*targetAttribute + lowerBound;
           insufficientIndex = insufficientIndex + 1;
        else
            pValues(pIndex,1) = 10*targetAttribute + lowerBound;
            pValues(pIndex,2:10) = getPValueUsingModifiedTTest2(targetGroup,remainingGroup);
            pIndex = pIndex + 1;
        end
        clearvars targetGroup remainingGroup;
        targetGroupIndex = 1;
        remainingGroupIndex = 1;
    end
end
index = 1;
for k = 1 : size(pValues,1)
   test = true;
   for j = 2 : size(pValues,2)
      if pValues(k,j) > .1 || pValues(k,j) < -.1
         test = false; 
      end
   end
   if test
       significantResults(index,:) = pValues(k,:);
       index = index + 1;
   end
end
