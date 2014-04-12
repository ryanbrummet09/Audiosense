%next we find Spearman's rank correlation coefficients accross the
%perception attributes.  First we must group all the relevant values though
%becuase of the holes in the data (matlab doesn't handle NaN well).
%PerceptionValues is of the form spAVG, leAVG, ldAVG, ld2AGV, lclAVG, apAVG, 
%qolAVG, imAVG, stAVG
for k = 1 : 9
    temp = extractedData(:,13 + k);
    temp2 = temp(temp >= 0);
    temp3 = temp(temp < 0);
    temp2 = [temp2',temp3'];
    perceptionAvgStdOverall(k) = mean(temp2);
end
spearmanVals = zeros([9,9]);
%while we used all non NaN values to find the avg for each perception,
%given two attributes a and b, we will only compare them across samples
%that they have in common.
for k = 1 : 9
   for i = 1 : 9
       index = 1;
       tempki = 0;
       tempk2 = 0;
       tempi2 = 0;
       for j = 1 : size(extractedData,1)
           if (extractedData(j,(13 + k)) >= 0 || extractedData(j,(13 + k)) < 0) && (extractedData(j,(13 + i)) >= 0 || extractedData(j,(13 + i)) < 0)
               tempki = tempki + ((extractedData(j,(13 + k)) - perceptionAvgStdOverall(k))*(extractedData(j,(13 + i)) - perceptionAvgStdOverall(i)));
               tempk2 = tempk2 + ((extractedData(j,(13 + k)) - perceptionAvgStdOverall(k))^2);
               tempi2 = tempi2 + ((extractedData(j,(13 + i)) - perceptionAvgStdOverall(i))^2);
           end
       end
       spearmanVals(k,i) = tempki / ((tempk2*tempi2)^(1/2));
   end
end

clearvars temp;

totalSampleSetSize = size(extractedData,1);
trainingSetSize = floor(4*(totalSampleSetSize / 5));
testingSetSize = ceil(totalSampleSetSize / 5);
trainingIndex = 1;
testingIndex = 1;
for k = 1 : 5: totalSampleSetSize
    if rem(k,5) == 0 && k < totalSampleSetSize - 5
        
        while size(trainingSet,1) < trainingSetSize
            trainingSet(trainingIndex,:) = extractedData(k,:);
            trainingIndex = trainingIndex + 1;
            k = k + 1;
        end
        while size(testingSet,1) < testingSetSize
            testingSet(testingIndex,:) = extractedData(k,:);
            testingIndex = testingIndex + 1;
            k = k + 1;
        end
        clearvars testingIndex trainingIndex;
        break;
    else
        temp = randi(5);
        testingSet(testingIndex,:) = extractedData(k - 1 + temp,:);
        testingIndex = testingIndex + 1;
        for j = 1 : 5
           if j ~= temp
              trainingSet(trainingIndex,:) = extractedData(k - 1 + temp,:); 
              trainingIndex = trainingIndex + 1;
           end
        end
    end 
end

clearvars temp;
mapDestination = 9;
polyDegree = 5;
mappingCoef = zeros(9,polyDegree + 1);
for k = 1: 9
   if k ~= mapDestination
       index = 1;
       for j = 1 : size(trainingSet,1)
          if (trainingSet(j,13 + mapDestination) >= 0 && (trainingSet(j,13 + k)) >= 0)
             temp(index,1) = trainingSet(j,13 + k);
             temp(index,2) = trainingSet(j,13 + mapDestination);
             index = index + 1;
          end
       end
       %highest degree at highest index
       mappingCoef(k,:) = fliplr(polyfit(temp(:,1),temp(:,2),polyDegree));
       clearvars dummyVals;
       for h = 1: 100
           %we must censor our results to be on the interval [0,100]
           convertedVal = 0;
           for g = polyDegree: -1: 0
               convertedVal = convertedVal + (h^g)*mappingCoef(k,g + 1);
           end 
           if convertedVal > 100
               dummyVals(h) = 100;
           elseif convertedVal < 0
               dummyVals(h) = 0;
           else
               dummyVals(h) = convertedVal;
           end
       end
       figure;
       hold on;
       scatter(temp(:,1),temp(:,2),'b');
       plot(dummyVals,'r');
       hold off;
       axis([0 100 0 100]);
       if k == 1
           ylabel(mapDestination);
           xlabel('sp');
           %title(num2str(mapDestination) + 'and sp');
       elseif k == 2
           ylabel(mapDestination);
           xlabel('le');
           %title(num2str(mapDestination) + 'and le');
       elseif k == 3
           ylabel(mapDestination);
           xlabel('ld');
           %title(num2str(mapDestination) + 'and ld');
       elseif k == 4
           ylabel(mapDestination);
           xlabel('ld2');
           %title(num2str(mapDestination) + 'and ld2');
       elseif k == 5
           ylabel(mapDestination);
           xlabel('lcl');
           %title(num2str(mapDestination) + 'and lcl');
       elseif k == 6
           ylabel(mapDestination);
           xlabel('ap');
           %title(num2str(mapDestination) + 'and ap');
       elseif k == 7
           ylabel(mapDestination);
           xlabel('qol');
           %title(num2str(mapDestination) + 'and qol');
       elseif k == 8
           ylabel(mapDestination);
           xlabel('im');
           %title(num2str(mapDestination) + 'and im');
       elseif k == 9
           ylabel(mapDestination);
           xlabel('st');
           %title(num2str(mapDestination) + 'and st');
       end
       clearvars temp;
   else
      for j = 1 : size(mappingCoef,2)
         mappingCoef(k,j) = 1; 
      end
   end
end
adjTestingSet = testingSet;
for k = 1 : size(testingSet,1)
    for j = 1 : 9
       if j ~= mapDestination
          %we must censor our results to be on the interval [0,100]
          convertedVal = 0;
          for g = polyDegree: -1: 0
              convertedVal = convertedVal + (testingSet(k,13 + j)^g)*mappingCoef(j,g + 1);
          end
          if convertedVal > 100
              adjTestingSet(k,13 + j) = 100;
          elseif convertedVal < 0
              adjTestingSet(k,13 + j) = 0;
          else
              adjTestingSet(k,13 + j) = convertedVal;
          end
       end
    end
end
for k = 1 : 9
    clearvars tempError;
    tempErrorIndex = 1;
    for j = 1 : size(testingSet,1)
        if testingSet(j,13 + k) >= 0
            tempError(tempErrorIndex) = abs(testingSet(j,13 + k) - adjTestingSet(j,13 + k));
            tempErrorIndex = tempErrorIndex + 1;
        end
    end
    error(k,1) = mean(tempError);
    error(k,2) = median(tempError);
    error(k,3) = max(tempError);
end
error(:,1)
mean(error(:,1))


%convert all values and see if we get normal distribution
adjExtractedData = extractedData;
for k = 1 : size(extractedData,1)
    for j = 1 : 9
        %we must censor our results to be on the interval [0,100]
        convertedVal = 0;
        for g = polyDegree: -1: 0
            convertedVal = convertedVal + (adjExtractedData(k,13 + j)^g)*mappingCoef(j,g + 1);
        end
        if convertedVal > 100
            adjExtractedData(k,13 + j) = 100;
        elseif convertedVal < 0
            adjExtractedData(k,13 + j) = 0;
        else
            adjExtractedData(k,13 + j) = convertedVal;
        end
    end
end
for k = 1 : size(adjExtractedData,1)
    index = 0;
    sum1 = 0;
    if adjExtractedData(k,14) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,14);
    end
    if adjExtractedData(k,15) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,15);
    end
    if adjExtractedData(k,16) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,16);
    end
    if adjExtractedData(k,17) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,17);
    end
    if adjExtractedData(k,18) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,18);
    end
    if adjExtractedData(k,19) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,19);
    end
    if adjExtractedData(k,20) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,20);
    end
    if adjExtractedData(k,21) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,21);
    end
    if adjExtractedData(k,22) >= 0
        index = index + 1;
        sum1 = sum1 + adjExtractedData(k,22);
    end
    if index > 0
        distributionSetTest(k) = sum1/index;
    else
        distributionSetTest(k) = NaN;
    end
end
%hist(distributionSetTest,100);
%title('Combined Attributes using Importance as Target');
%xlabel('Rating');
%ylabel('Quantity');