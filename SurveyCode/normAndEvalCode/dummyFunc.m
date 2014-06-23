%Ryan Brummet
%University of Iowa

function [ dummyScores ] = dummyFunc( combinedScores, inputContexts )
    %takes as input combinedScore table and context variables then converts
    %the context variables to dummy variables of the form 'ac', 'lc', 'tf', 
    %'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition' where the order will
    %be constent but variables may be absent.
    
    %gives the number of possilbilies for each context.  Order is the same 
    %as described above.
    conditions = unique(combinedScores.condition);
    contextAmounts = [7 5 4 3 3 4 3 2 4 sum(~isnan(unique(combinedScores.condition)))];
    
    allContexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
    presentContexts = zeros(1,10);
    
    for k = 1 : size(inputContexts,2)
        presentContexts(1,find(1 == ismember(allContexts, inputContexts(k)))) = 1;
    end
    
    %here we need to load the hearing loss info for each patient.  For now
    %we are just going to create a column vector of zeros as a stand in
    hearingLossInfo = zeros(size(combinedScores,1),1);
    
    %get the number of columns that we are going to need for each variable
    %where the order is hearingLossInfo ac lc tf vc tl nl rs cp nz
    %condition.  Like before the order will stay the same but variables may
    %be missing
    numColNeeded = [size(hearingLossInfo,2) contextAmounts .* presentContexts];
    
    %create dummyScores matrix of zeros
    dummyScores = zeros(size(combinedScores,1), sum(numColNeeded) + 1);
    
    %build the dummyScores.  First input hearing loss info then dummy vars.
    %Finally add scores.
    
    %here we add hearing loss info
    
    %here we add dummy vars
    for k = 1 : size(combinedScores,1)
        for j = 1 : size(allContexts,2)
            if numColNeeded(1,1 + j) ~= 0
                if ~isnan(combinedScores.(allContexts{j})(k))
                    if strcmp(allContexts{j},'condition')
                        dummyScores(k,sum(contextAmounts(1,1:j)) - contextAmounts(1,j) + find(combinedScores.(allContexts{j})(k) == conditions) + size(hearingLossInfo,2)) = 1;
                    else
                        dummyScores(k,sum(contextAmounts(1,1:j)) - contextAmounts(1,j) + combinedScores.(allContexts{j})(k) + size(hearingLossInfo,2)) = 1;
                    end
                end
            end
            
        end
    end
    
    %here we add the score
    dummyScores(:,size(dummyScores,2)) = combinedScores.score;
    
    %convert dummyScores into a table and assign variable names
    dummyScores = [array2table(combinedScores.patient) array2table(dummyScores)];
    dummyScores.Properties.VariableNames{'Var1'} = 'patient';
    index = 1;
    for k = 1 : size(numColNeeded,2) + 1
        if k > size(hearingLossInfo,2) && k <= size(numColNeeded,2)
            if presentContexts(1, k - size(hearingLossInfo,2)) == 0
                continue; 
            end
        end
        if k <= size(numColNeeded,2)
            for j = 1 : numColNeeded(1,k)
                if k == 1
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('hearing',num2str(j));
                elseif k == 2
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('ac',num2str(j));
                elseif k == 3
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('lc',num2str(j));
                elseif k == 4
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('tf',num2str(j));
                elseif k == 5
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('vc',num2str(j));
                elseif k == 6
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('tl',num2str(j));
                elseif k == 7
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('nl',num2str(j));
                elseif k == 8
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('rs',num2str(j));
                elseif k == 9
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('cp',num2str(j));
                elseif k == 10
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('nz',num2str(j));
                else 
                    dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = strcat('condition',num2str(conditions(j)));
                end
                index = index + 1;
            end
        else
            dummyScores.Properties.VariableNames{strcat('dummyScores',num2str(index))} = 'score';
        end
    end
end

