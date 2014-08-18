%Ryan Brummet
%University of Iowa

%Builds box plots of output scores for each context

%% initialize
clear;
close all;
clc;
                    %bic (bayesian information criterion), rsquared, adjrsquared
combineTech = 'SUMADJ'; %can be AVG, SUM, MEDIAN, STD
targetAttr = 'NoMap';
normTech = 'NoNorm';  %can be NoNorm, GlobalNorm, or UserNorm
mapTech = 'robustMappingGraphs';
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',targetAttr,'_Using',combineTech,normTech,'.mat'));
contexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};

if strcmp(normTech,'NoNorm')
    normTech2 = 'notNormalized';
elseif strcmp(normTech,'GlobalNorm')
    normTech2 = 'globallyNormalized';
elseif strcmp(normTech,'UserNorm');
    normTech2 = 'userNormalized';
else
    error('an invalid value for normTech was given'); 
end

saveLocation = {char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/',mapTech,'/',normTech2,'/','combinedScoreUsing',combineTech,targetAttr,'/patientDist'))};

load(dataFileName);

%create and save figs
data = [trainingSet;validationSet];
patients = unique(data.patient);
for a = 1 : size(patients,1)
    combinedScoreData = data(data.patient == patients(a),:);
    
    mkdir(char(strcat(saveLocation,'/patient',num2str(patients(a)))));
    for k = 1 : size(contexts,2)
        contextValues = unique(combinedScoreData.(contexts{k}));
        contextValues(isnan(contextValues)) = [];
        plotVals = nan(size(combinedScoreData,1),size(contextValues,1));
        for j = 1 : size(combinedScoreData,1)
            if ~isnan(combinedScoreData.(contexts{k})(j))
                if ~strcmp(contexts{k},'condition')
                    plotVals(j,combinedScoreData.(contexts{k})(j)) = combinedScoreData.score(j);
                else
                    plotVals(j,find(contextValues == combinedScoreData.(contexts{k})(j))) = combinedScoreData.score(j);
                end
            end
        end
        index = size(plotVals,2);
        for g = 1 : index
            if sum(~isnan(plotVals(:,g))) == 0
                plotVals(:,g) = []; 
                index = index - 1;
            end
        end
        boxplot(plotVals, 'labels', contextValues);
        title(char(strcat(contexts{k}, {' '}, 'Combined Score Distribution Using', {' '}, combineTech,{' For Patient'},num2str(patients(a)))));
        xlabel('Context Value');
        savefig(gcf,char(strcat(saveLocation,'/patient',num2str(patients(a)),contexts{k},'ScoreBoxPlot')));
        close all;
    end
end

