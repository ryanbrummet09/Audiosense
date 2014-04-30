%we want to combine all perceptions into a singular value.  First we will
%see if this is possilbe.  If it isn't we may use two values, three, etc,
%increasing the number of values we are using until we a suitable set of
%values that we can reduce the perceptions to.
close all;
perceptionNames = {'sp' 'le' 'ld' 'ld2' 'lcl' 'ap' 'qol' 'im' 'st'};
 h = boxplot(extractedData(:,[14:22]), perceptionNames);
 for k = 0 : 8
     upper = get(h(3 + (k * 7)),'ydata');
     lower = get(h(4 + (k * 7)),'ydata');
     perceptionRange(k + 1) = abs(upper(1)) - abs(lower(1)); 
 end
 bar(perceptionRange);
 set(gca,'XTickLabel',perceptionNames);

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
totalSampleSetSize = size(extractedData,1);
trainingSetSize = floor(4*(totalSampleSetSize / 5));
testingSetSize = ceil(totalSampleSetSize / 5);
trainingIndex = 1;
for k = 1 : totalSampleSetSize
    if rem(k,5) == 0 && k < totalSampleSetSize - 5
        
        while size(trainingSet,1) < trainingSetSize
            trainingSet(trainingIndex,:) = extractedData(k,:);
            k = k + 1;
        end
    end
        
        
end
%creates spearman coefficient table
f = figure('Position',[100,100,720,200]);
uitable('Parent', f,'Data', spearmanVals, 'ColumnName', perceptionNames, 'RowName', perceptionNames, 'Position', [0,0,900,200]);
clearvars temp;
%plots attribute pairs (two different attributes) of each sample where both
%attributes are not NaN
for j = 1 : size(extractedData,1)
    if (extractedData(j,15) >= 0 || extractedData(j,15) < 0) && (extractedData(j,22) >= 0 || extractedData(j,22) < 0)
        temp(j,1) = extractedData(j,15);
        temp(j,2) = extractedData(j,22);
    end
end

figure;
scatter(temp(:,1),temp(:,2));
degrees = polyfit(temp(:,1),temp(:,2),5);
for k = 1 : size(extractedData,1)
   output(k) =(k^5)*degrees(1) + (k^4)*degrees(2) + (k^3)*degrees(3) + (k^2)*degrees(4) + k * degrees(5) + degrees(6); 
end
hold on;
plot(output);
axis([0 100 0 100]);
hold off;
for k = 1 : 9
   spearmanTotal(k) = mean(abs(spearmanVals(k,:))); 
end
figure;
bar(spearmanTotal);
