% Ryan Brummet
% University of Iowa
%
% Iterates through a folder containing files that were created using 
% buildPoolDataMDL.  For each .mat file the errorStruct variable is 
% extracted and used to find the mean and median abs error for each outer 
% fold.
%
% Params
%   string: folderLocation - gives the location of the folder to iterate
%                            through.  Must include / at the end to work.
% Return
%   table: meanErrors - a table of the mean errors of each fold for each
%                       .mat file.  Rows are folds and columns indicate the
%                       response of the file (it is assumed that there is
%                       at most one file for each response in a folder).
%   table: medianErrors = a table of the median erros for each fold for
%                         each .mat file.  Rows are folds and columns
%                         indicate the resonse of the file (it is assuemd
%                         that there is a at most one file for each
%                         response in a folder).
%

function [ meanErrors, medianErrors ] = getErrorFromErrorStructPool( folderLocation )

    fileNames = dir(folderLocation);
    fileNames = extractfield(fileNames, 'name');
   
    %remove non data files
    fileNames(1:2) = [];
    
    varIndex = 1;
    for k = 1 : size(fileNames,2)
        temp = strsplit(fileNames{k},'.');
        if strcmp(temp{2},'mat')
            thisErrorStruct = load(strcat(folderLocation,fileNames{k}),'errorStruct');
            settings = load(strcat(folderLocation,fileNames{k}),'SVMSettings');
            varNames{varIndex} = settings.SVMSettings.dataTable(:,end).Properties.VariableNames{1};
            for j = 1 : settings.SVMSettings.crossValFolds
                pred = strcat('outerPred',num2str(j));
                real = strcat('outerReal',num2str(j));
                meanErrors(j,varIndex) = mean(abs(thisErrorStruct.errorStruct.(pred) - thisErrorStruct.errorStruct.(real)));
                medianErrors(j,varIndex) = median(abs(thisErrorStruct.errorStruct.(pred) - thisErrorStruct.errorStruct.(real)));
            end
            varIndex = varIndex + 1;
        end
    end
    
    meanErrors = array2table(meanErrors,'VariableNames',varNames);
    medianErrors = array2table(medianErrors,'VariableNames',varNames);
    
    figure;
    boxplot(table2array(meanErrors));
    axis([0,size(varNames,2) + 1,0,ceil(max(max(max(table2array(meanErrors))),max(max(table2array(medianErrors)))) / 10) * 10]);
    set(gca,'XLim',[0 size(varNames,2) + 1],'XTick',1:size(varNames,2),'XTickLabel',meanErrors.Properties.VariableNames);
    xlabel('Response');
    ylabel('Mean Absolute Error');
    title('Variation of Absolute Mean Error across Outer Folds for Various Responses')
    
    figure;
    boxplot(table2array(medianErrors));
    axis([0,size(varNames,2) + 1,0,ceil(max(max(max(table2array(meanErrors))),max(max(table2array(medianErrors)))) / 10) * 10]);
    set(gca,'XLim',[0 size(varNames,2) + 1],'XTick',1:size(varNames,2),'XTickLabel',medianErrors.Properties.VariableNames);
    xlabel('Response');
    ylabel('Median Absolute Error');
    title('Variation of Absolute Median Error across Outer Folds for Various Responses')
    
end

