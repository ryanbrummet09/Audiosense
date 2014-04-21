indices = randperm(size(combinedData,1),floor(size(combinedData,1) * .8));
trainingIndex = 1;
testingIndex = 1;
for k = 1 : size(combinedData,1)
   if ismember(k,indices)
       trainingSet(trainingIndex,:) = combinedData(k,:);
       trainingIndex = trainingIndex + 1;
   else
       testingSet(testingIndex,:) = combinedData(k,:);
       testingIndex = testingIndex + 1;
   end
end