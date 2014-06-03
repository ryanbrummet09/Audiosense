%Ryan Brummet
%University of Iowa

function [ ] = testOverfitting( data, mapInfo )
    %mapInfo should be a 1x11 vector consisting of targetAttr, mapAttr, 
    % %Samples, deg, mapCoef, and RMSD where mapCoef consists of 6 columns
    %(decreasing order)
    
    labels{1} = 'sp';
    labels{2} = 'le';
    labels{3} = 'ld';
    labels{4} = 'ld2';
    labels{5} = 'lcl';
    labels{6} = 'ap';
    labels{7} = 'qol';
    labels{8} = 'im';
    labels{9} = 'st';
    
    target = labels{mapInfo(1,1)};
    
    figure;
    for k = 1 : 9
        if k ~= mapInfo(1,1)
            
            %find mapping pairs
            clearvars mapPairSet;
            mapPairSet(1,2) = NaN;
            indexTemp = 1;
            for n = 1 : size(data,1)
                if ~isnan(data(n,13 + k)) && ...
                    ~isnan(data(n,13 + mapInfo(1,1)))
                    mapPairSet(indexTemp,1) = data(n,13 + k);
                    mapPairSet(indexTemp,2) = data(n,13 + mapInfo(1,1));
                    indexTemp = indexTemp + 1;
                end
            end
            
            %find RMSD value for all possible validation/training set sizes
            numOfSamples = size(mapPairSet,1);
            degIndex = find(mapInfo(:,2) == k);
            
            for j = 1 : numOfSamples - 1
                clearvars trainingSet validationSet
                indices = randperm(numOfSamples);
                trainingSet = mapPairSet(indices(1:j),:);
                validationSet = mapPairSet(indices(j + 1:numOfSamples),:);
                temp = polyfit(trainingSet(:,1),trainingSet(:,2), ...
                    mapInfo(degIndex,4));
                
                mapCoef = zeros(1,6);
                if mapInfo(degIndex,4) == 1
                    mapCoef(1,5) = temp(1);
                    mapCoef(1,6) = temp(2);
                elseif mapInfo(degIndex,4) == 2
                    mapCoef(1,4) = temp(1);
                    mapCoef(1,5) = temp(2);
                    mapCoef(1,6) = temp(3);
                elseif mapInfo(degIndex,4) == 3
                    mapCoef(1,3) = temp(1);
                    mapCoef(1,4) = temp(2);
                    mapCoef(1,5) = temp(3);
                    mapCoef(1,6) = temp(4);
                elseif mapInfo(degIndex,4) == 4
                    mapCoef(1,2) = temp(1);
                    mapCoef(1,3) = temp(2);
                    mapCoef(1,4) = temp(3);
                    mapCoef(1,5) = temp(4);
                    mapCoef(1,6) = temp(5);
                else
                    mapCoef(1,1) = temp(1);
                    mapCoef(1,2) = temp(2);
                    mapCoef(1,3) = temp(3);
                    mapCoef(1,4) = temp(4);
                    mapCoef(1,5) = temp(5);
                    mapCoef(1,6) = temp(6);
                end
                
                trainingSum = 0;
                validationSum = 0;
                for s = 1 : size(trainingSet,1)
                   trainingSum = trainingSum + ((mapCoef(1)*( ...
                       trainingSet(s,1)^5) + mapCoef(2)*( ...
                       trainingSet(s,1)^4) + mapCoef(3)*( ...
                       trainingSet(s,1)^3) + mapCoef(4)*( ...
                       trainingSet(s,1)^2) + mapCoef(5)*( ...
                       trainingSet(s,1)^1) + mapCoef(6)*( ...
                       trainingSet(s,1)^0)) - (trainingSet(s,2)))^2; 
                end
                trainingRMSD(j) = sqrt(trainingSum / size(trainingSet,1));
                for s = 1 : size(validationSet,1)
                   validationSum = validationSum + ((mapCoef(1)*( ...
                       validationSet(s,1)^5) + mapCoef(2)*( ...
                       validationSet(s,1)^4) + mapCoef(3)*( ...
                       validationSet(s,1)^3) + mapCoef(4)*( ...
                       validationSet(s,1)^2) + mapCoef(5)*( ...
                       validationSet(s,1)^1) + mapCoef(6)*( ...
                       validationSet(s,1)^0)) - (validationSet(s,2)))^2; 
                end
                validationRMSD(j) = sqrt(validationSum / size( ...
                    validationSet,1));
            end
            
            %find the number of samples that were used to generate the
            %actual mapping coefficients for the target we are examining
            %(this mapping coefficients were passed to this function in the
            %mapInfo variable)
            numTrainingSamples = round(mapInfo(degIndex,3)/100*size(data,1) ...
                *(4/5)*(4/5));
            maximum = max(max(trainingRMSD),max(validationRMSD));
            minimum = min(min(trainingRMSD),min(validationRMSD));
            
            %plot info
            subplot(3,3,k);
            scatter(1:numOfSamples - 1,trainingRMSD,'r');
            hold on;
            scatter(1:numOfSamples - 1,validationRMSD,'b');
            plot([numTrainingSamples numTrainingSamples],...
                [20 0],'g');
            hold off;
            ylabel('RMSD');
            xlabel('Number of Training Samples');
            title(strcat(labels{k}, {' '}, 'mapped onto', {' '}, target));
            axis([0 numOfSamples 0 20]);
            legend('training','validation','used');
            clearvars trainingRMSD validationRMSD
        else
            continue; 
        end
    end
end

