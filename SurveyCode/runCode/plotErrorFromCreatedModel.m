data = [trainingTable;validationTable];
usedContexts{1,size(usedContexts,2) + 1} = 'patient';
for k = 1 : size(usedContexts,2)
    plotVals = nan(size(data,1),size(unique(data.(usedContexts{k})),1));
    boxLabels = [];
    index = 0;
    for j = 0 : size(unique(data.(usedContexts{k})),1) - 1
         train = absErrorTraining(trainingTable.(usedContexts{k}) == j);
         val = absErrorValidation(validationTable.(usedContexts{k}) == j);
         plotVals(1:size(train,1),index + 1) = train;
         boxLabels{index + 1} = strcat('Tr',num2str(j));
         index = index + 1;
         plotVals(1:size(val,1),index + 1) = val;
         boxLabels{index + 1} = strcat('V',num2str(j));
         index = index + 1;
    end
    boxplot(plotVals,'labels',boxLabels);
    title(strcat(usedContexts{k},{' Error'}));
    savefig(gcf,char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/modelErrorFromLastExecution/',usedContexts{k})));
end