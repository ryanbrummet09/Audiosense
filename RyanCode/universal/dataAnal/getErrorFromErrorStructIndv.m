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
%   string: groupVar - gives the name of the predictor of which a model was
%                      created for each unique type.
% Return
%   table: meanErrors - a table of the mean errors of each fold for each
%                       .mat file.  Rows are folds and columns indicate the
%                       group value of the file.
%   table: medianErrors = a table of the median erros for each fold for
%                         each .mat file. Rows are folds and columns 
%                         indicate the group value of the file.
%

function [ meanErrors, medianErrors ] = getErrorFromErrorStructIndv( folderLocation, groupVar )

    fileNames = dir(folderLocation);
    fileNames = extractfield(fileNames, 'name');
   
    %remove non data files
    fileNames(1:2) = [];
    
    varIndex = 1;
    okay = false;
    for k = 1 : size(fileNames,2)
        temp = strsplit(fileNames{k},'.');
        if strcmp(temp{2},'mat')
            temp = strsplit(temp{1},groupVar);
            if strcmp(groupVar,'condition')
                if str2double(temp{2}) == 7
                    temp{2} = '21';
                elseif str2double(temp{2}) == 8
                    temp{2} = '22';
                elseif str2double(temp{2}) == 9
                    temp{2} = '23';
                elseif str2double(temp{2}) == 10
                    temp{2} = '24';
                elseif str2double(temp{2}) == 0
                    temp{2} = '99';
                end
            end
            tableNames{varIndex} = strcat(groupVar,temp{2});
            plotNames{varIndex} = temp{2};
            
            thisErrorStruct = load(strcat(folderLocation,fileNames{k}),'errorStruct');
            settings = load(strcat(folderLocation,fileNames{k}),'SVMSettings');
            if ~isfield(thisErrorStruct,'errorStruct') || ~isfield(settings,'SVMSettings')
                if okay
                    meanErrors(:,varIndex) = NaN;
                    medianErrors(:,varIndex) = NaN;
                end
                varIndex = varIndex + 1;
                continue;
            end
            
            if k == 1
                okay = true;
            elseif ~okay
                meanErrors(1:settings.SVMSettings.crossValFolds,1:varIndex - 1) = NaN;
                medianErrors(1:settings.SVMSettings.crossValFolds,1:varIndex - 1) = NaN;
                okay = true;
            end
            
            if varIndex == 1 
                varName = settings.SVMSettings.dataTable(:,end).Properties.VariableNames{1};
            end
            
            for j = 1 : settings.SVMSettings.crossValFolds
                pred = strcat('outerPred',num2str(j));
                real = strcat('outerReal',num2str(j));
                meanErrors(j,varIndex) = mean(abs(thisErrorStruct.errorStruct.(pred) - thisErrorStruct.errorStruct.(real)));
                medianErrors(j,varIndex) = median(abs(thisErrorStruct.errorStruct.(pred) - thisErrorStruct.errorStruct.(real)));
            end
            varIndex = varIndex + 1;
        end
    end
    
    temp = str2double(plotNames);
    [plotNames,index] = sort(temp);
    tableNames = tableNames(index);
    meanErrors = meanErrors(:,index);
    medianErrors = medianErrors(:,index);
    
    meanErrors = array2table(meanErrors,'VariableNames',tableNames);
    medianErrors = array2table(medianErrors,'VariableNames',tableNames);
    
    figure;
    boxplot(table2array(meanErrors));
    axis([0,size(plotNames,2) + 1,0,ceil(max(max(max(table2array(meanErrors))),max(max(table2array(medianErrors)))) / 10) * 10]);
    set(gca,'XLim',[0 size(plotNames,2) + 1],'XTick',1:size(plotNames,2),'XTickLabel',plotNames);
    xlabel(groupVar);
    ylabel('Mean Absolute Error');
    title(strcat('Variation of Absolute Mean Error across Outer Folds for Various ',{' '},groupVar,'s'));
    savefig(strcat(folderLocation,varName,'MeanErrorBoxPlotIndv',groupVar));
    
    figure;
    boxplot(table2array(medianErrors));
    axis([0,size(plotNames,2) + 1,0,ceil(max(max(max(table2array(meanErrors))),max(max(table2array(medianErrors)))) / 10) * 10]);
    set(gca,'XLim',[0 size(plotNames,2) + 1],'XTick',1:size(plotNames,2),'XTickLabel',plotNames);
    xlabel(groupVar);
    ylabel('Median Absolute Error');
    title(strcat('Variation of Absolute Median Error across Outer Folds for Various ',{' '},groupVar,'s'));
    savefig(strcat(folderLocation,varName,'MedianErrorBoxPlotIndv',groupVar));
    
end