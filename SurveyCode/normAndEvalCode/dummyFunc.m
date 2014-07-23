%Ryan Brummet
%University of Iowa

function [ dummyScores ] = dummyFunc( combinedScores, inputContexts, useDemoData, useNaNVals )
    %takes as input combinedScore table and context variables then converts
    %the context variables to dummy variables of the form 'ac', 'lc', 'tf', 
    %'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition' where the order will
    %be constent but variables may be absent.
    
    %gives the number of possilbilies for each context.  Order is the same 
    %as described above.
    conditions = unique(combinedScores.condition);
    contextAmounts = [2 2 2 7 5 4 3 3 4 3 2 4 sum(~isnan(unique(combinedScores.condition)))];
    
    allContexts = {'hau', 'listening', 'userinitiated', 'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz','condition'};
    presentContexts = zeros(1,10);
    
    for k = 1 : size(inputContexts,2)
        presentContexts(1,find(1 == ismember(allContexts, inputContexts(k)))) = 1;
    end
    
    %get the number of columns that we are going to need for each variable
    %where the order is hearingLossInfo hau ac lc tf vc tl nl rs cp nz
    %condition.  Like before the order will stay the same but variables may
    %be missing
    numColNeeded = contextAmounts .* presentContexts;
    
    %create dummyScores matrix of zeros
    dummyScores = zeros(size(combinedScores,1),sum(numColNeeded) + 1);
    
    %here we add dummy vars
    for k = 1 : size(combinedScores,1)
        for j = 1 : size(allContexts,2)
            if numColNeeded(1,j) == 0
                continue; 
            else
                if ~isnan(combinedScores.(allContexts{j})(k))
                    if strcmp(allContexts{j},'condition')
                        dummyScores(k,sum(numColNeeded(1,1:j)) - numColNeeded(1,j) + find(combinedScores.(allContexts{j})(k) == conditions)) = 1;
                    else
                        dummyScores(k,sum(numColNeeded(1,1:j)) - numColNeeded(1,j) + combinedScores.(allContexts{j})(k)) = 1;
                    end
                else
                    if useNaNVals
                        dummyScores(k,sum(contextAmounts(1,1:j)) - contextAmounts(1,j) + 1 : sum(contextAmounts(1:j))) = NaN;
                    end
                end
            end
        end
    end
    
    %here we add the score
    dummyScores(:,size(dummyScores,2)) = combinedScores.score;
    
    %if useDemoData is true we add demographic data in the order gender(dummy2{M,F}),
    %education(dummy5{noHS, HS, PostHS, College, GRAD}), YearsSinceHLOnset,
    %YearsOfHAUse, snlLeft, snlRight, pta512Left, pta124Left, pta512Right,
    %pta124Right.  noHS is no GED or HS diploma(1), HS is GED or HS diploma(2),
    %PostHS is Vocational or some college(3), College is 4 yr ba or bs(4), GRAD
    %is graduate school(5).  To satisify indeterminant values, a-b changed
    %to mean(a,b),strings are given as NaN when numbers are expected, and
    %a+ is given a value of a for YearsSinceHLOnset and YearsOfHAUse.  If
    %useDemoData is false, patient id's are used instead.
    
    if useDemoData
        load('demographics.mat');
        load('ptaInfo.mat');
    
        demoData = zeros(size(combinedScores.patient,1),15);
        for k = 1 : size(combinedScores.patient,1)
            indexDemo = find(combinedScores.patient(k,1) == demographics.Subject);
            indexPTA = find(combinedScores.patient(k,1) == pta.Subject);
            if strcmp(demographics.Gender(indexDemo,1),'M')
                demoData(k,1) = 1;
            elseif strcmp(demographics.Gender(indexDemo,1),'F')
                demoData(k,2) = 1;
            else
                demoData(k,1) = NaN;
                demoData(k,2) = NaN;
            end
            if demographics.Education(indexDemo,1) == 1
                demoData(k,3) = 1;
            elseif demographics.Education(indexDemo,1) == 2
                demoData(k,4) = 1;
            elseif demographics.Education(indexDemo,1) == 3
                demoData(k,5) = 1;
            elseif demographics.Education(indexDemo,1) == 4
                demoData(k,6) = 1;
            elseif demographics.Education(indexDemo,1) == 5
                demoData(k,7) = 1;
            else
                demoData(k,3) = NaN;
                demoData(k,4) = NaN;
                demoData(k,5) = NaN;
                demoData(k,6) = NaN;
                demoData(k,7) = NaN;
            end
            demoData(k,8) = demographics.HLOnset(indexDemo,1);
            demoData(k,9) = demographics.DurationHAUse(indexDemo,1);
            demoData(k,10) = demographics.SNRLossLeft(indexDemo,1);
            demoData(k,11) = demographics.SNRLossRight(indexDemo,1);
            demoData(k,12) = pta.pta512Left(indexPTA,1);
            demoData(k,13) = pta.pta124Left(indexPTA,1);
            demoData(k,14) = pta.pta512Right(indexPTA,1);
            demoData(k,15) = pta.pta124Right(indexPTA,1);
        end
        
        %convert dummyScores into a table, assign variable names, and reorder
        %the column order of the table
        dummyScores = [array2table(demoData) array2table(dummyScores)];
        dummyScores.Properties.VariableNames{'demoData1'} = 'Male';
        dummyScores.Properties.VariableNames{'demoData2'} = 'Female';
        dummyScores.Properties.VariableNames{'demoData3'} = 'noHS';
        dummyScores.Properties.VariableNames{'demoData4'} = 'HS';
        dummyScores.Properties.VariableNames{'demoData5'} = 'PostHS';
        dummyScores.Properties.VariableNames{'demoData6'} = 'College';
        dummyScores.Properties.VariableNames{'demoData7'} = 'Grad';
        dummyScores.Properties.VariableNames{'demoData8'} = 'HLOnsetYears';
        dummyScores.Properties.VariableNames{'demoData9'} = 'HAUserYears';
        dummyScores.Properties.VariableNames{'demoData10'} = 'SNRLeft';
        dummyScores.Properties.VariableNames{'demoData11'} = 'SNRRight';
        dummyScores.Properties.VariableNames{'demoData12'} = 'pta512Left';
        dummyScores.Properties.VariableNames{'demoData13'} = 'pta124Left';
        dummyScores.Properties.VariableNames{'demoData14'} = 'pta512Right';
        dummyScores.Properties.VariableNames{'demoData15'} = 'pta124Right';
    else
        uniquePatients = unique(combinedScores.patient);
        patients = dummyvar(combinedScores.patient);
        dummyScores = [array2table(patients) array2table(dummyScores)];
        for k = 1:size(uniquePatients,1)
            dummyScores.Properties.VariableNames{strcat('patients',num2str(k))} = strcat('Patient',num2str(uniquePatients(k))); 
        end
    end
    
    indexDemo = 1;
    
    for k = 1 : size(numColNeeded,2) + 1
        if k <= size(numColNeeded,2)
            if presentContexts(1,k) == 0
                continue; 
            end
            for j = 1 : numColNeeded(1,k)
                if k == 1
                    if j == 1
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'hauFALSE';
                    else
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'hauTRUE';
                    end
                elseif k == 2
                    if j == 1
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'listeningFALSE';
                    else
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'listeningTRUE';
                    end
                elseif k == 3
                    if j == 1
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'userInitFALSE';
                    else
                        dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'userInitTRUE';
                    end
                elseif k == 4
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('ac',num2str(j));
                elseif k == 5
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('lc',num2str(j));
                elseif k == 6
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('tf',num2str(j));
                elseif k == 7
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('vc',num2str(j));
                elseif k == 8
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('tl',num2str(j));
                elseif k == 9
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('nl',num2str(j));
                elseif k == 10
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('rs',num2str(j));
                elseif k == 11
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('cp',num2str(j));
                elseif k == 12
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('nz',num2str(j));
                else 
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = strcat('condition',num2str(conditions(j)));
                end
                indexDemo = indexDemo + 1;
            end
        else
            dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(indexDemo))} = 'score';
        end
    end
end

