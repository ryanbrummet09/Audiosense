% Ryan Brummet
% University of Iowa

function [ threshold ] = findUserScoreVarienceThreshold( data, numContexts)
    %first we need to produce a single score to describe a context
    inputContexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz'};
    index = 1;
    sampleContext = zeros(size(data,1),1);
    uniqueContext = -1;
    for j = 1 : size(data,1)
        for k = 2 : size(inputContexts,2) + 1
            if ~isnan(data.(inputContexts{k - 1})(j))
                if strcmp(inputContexts{k - 1},'condition')
                    sampleContext(j) = sampleContext(j) + data.(inputContexts{k - 1})(j);
                else
                    sampleContext(j) = sampleContext(j) + data.(inputContexts{k - 1})(j) * 10^k;
                end
            end
        end
        if (uniqueContext(1,1) == -1)
            uniqueContext(size(uniqueContext,1),1) = sampleContext(j);
            uniqueContext(size(uniqueContext,1),2) = 1;
        elseif sum(ismember(uniqueContext,sampleContext(j))) == 0
            uniqueContext(size(uniqueContext,1) + 1,1) = sampleContext(j);
            uniqueContext(size(uniqueContext,1),2) = 1;
        else
            uniqueContext(find(uniqueContext == sampleContext(j)),2) = uniqueContext(find(uniqueContext == sampleContext(j)),2) + 1;
        end
    end
    
    uniqueContext = flipud(sortrows(uniqueContext,2));
    for k = 1 : size(uniqueContext,1)
        uniqueContext(k,3) = k; 
    end
    for j = 1 : size(data,1)
         sampleContext(j) = uniqueContext(find(uniqueContext == sampleContext(j)),3);
    end
    
    scoreContextPair = [sampleContext data.score];
    for k = 1 : numContexts
        temp = (scoreContextPair(scoreContextPair(:,1) == k,2));
        meanAbsDevUsingMedian(k) = mean(abs(temp - median(temp)));
    end
    threshold = ceil(mean(meanAbsDevUsingMedian));
end

