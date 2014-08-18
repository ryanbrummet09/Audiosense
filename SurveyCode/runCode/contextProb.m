clear;
clc;

load('compositeScoreOn_le_UsingAVGNoNorm.mat');
data = [trainingSet; validationSet];
contexts = {'ac','lc','tf','vc','tl','nl','rs','cp','nz','condition'};
contexts2 = {'AC','LC','TF','VC','TL','NL','RS','CP','NZ','CND'};

%scale data contexts to be unique
index = 2;
for k = size(contexts,2) : -1 : 1
    if ~strcmp(contexts{k},'condition')
        data.(contexts{k}) = data.(contexts{k}) * 10^index;
        index = index + 1;
    end
end

index = 1;
%---one---
for k1 = 1 : size(contexts,2)
    temp = data.(contexts{k1});
    temp2 = unique(temp);
    temp2(isnan(temp2)) = [];
    for u = 1 : size(temp2,1)
        contextCount(index,1) = temp2(u);
        contextCount(index,2) = sum(temp == temp2(u));
        index = index + 1;
    end
end

%---two---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        temp = data.(contexts{k1}) + data.(contexts{k2}); 
        temp2 = unique(temp);
        temp2(isnan(temp2)) = [];
        for u = 1 : size(temp2,1)
            contextCount(index,1) = temp2(u);
            contextCount(index,2) = sum(temp == temp2(u));
            index = index + 1;
        end
    end
end

%---three---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            temp = data.(contexts{k1}) + data.(contexts{k2}) + data.(contexts{k3}); 
            temp2 = unique(temp);
            temp2(isnan(temp2)) = [];
            for u = 1 : size(temp2,1)
                contextCount(index,1) = temp2(u);
                contextCount(index,2) = sum(temp == temp2(u));
                index = index + 1;
            end
        end
    end
end

%---four---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                    data.(contexts{k3}) + data.(contexts{k4});
                temp2 = unique(temp);
                temp2(isnan(temp2)) = [];
                for u = 1 : size(temp2,1)
                    contextCount(index,1) = temp2(u);
                    contextCount(index,2) = sum(temp == temp2(u));
                    index = index + 1;
                end
            end
        end
    end
end

%---five---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                    temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                        data.(contexts{k3}) + data.(contexts{k4}) + ...
                        data.(contexts{k5});
                    temp2 = unique(temp);
                    temp2(isnan(temp2)) = [];
                    for u = 1 : size(temp2,1)
                        contextCount(index,1) = temp2(u);
                        contextCount(index,2) = sum(temp == temp2(u));
                        index = index + 1;
                    end 
                end
            end
        end
    end
end

%---six---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                    for k6 = k5 + 1 : size(contexts,2)
                        temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                            data.(contexts{k3}) + data.(contexts{k4}) + ...
                            data.(contexts{k5}) + data.(contexts{k6});
                        temp2 = unique(temp);
                        temp2(isnan(temp2)) = [];
                        for u = 1 : size(temp2,1)
                            contextCount(index,1) = temp2(u);
                            contextCount(index,2) = sum(temp == temp2(u));
                            index = index + 1;
                        end 
                    end
                end
            end
        end
    end
end

%---seven---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                   for k6 = k5 + 1 : size(contexts,2)
                       for k7 = k6 + 1 : size(contexts,2)
                           temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                               data.(contexts{k3}) + data.(contexts{k4}) + ...
                               data.(contexts{k5}) + data.(contexts{k6}) + ...
                               data.(contexts{k7});
                            temp2 = unique(temp);
                            temp2(isnan(temp2)) = [];
                            for u = 1 : size(temp2,1)
                                contextCount(index,1) = temp2(u);
                                contextCount(index,2) = sum(temp == temp2(u));
                                index = index + 1;
                            end 
                       end
                   end
                end
            end
        end
    end
end

%---eight---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                    for k6 = k5 + 1 : size(contexts,2)
                        for k7 = k6 + 1 : size(contexts,2)
                            for k8 = k7 + 1 : size(contexts,2)
                                temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                                    data.(contexts{k3}) + data.(contexts{k4}) + ...
                                    data.(contexts{k5}) + data.(contexts{k6}) + ...
                                    data.(contexts{k7}) + data.(contexts{k8});
                                temp2 = unique(temp);
                                temp2(isnan(temp2)) = [];
                                for u = 1 : size(temp2,1)
                                    contextCount(index,1) = temp2(u);
                                    contextCount(index,2) = sum(temp == temp2(u));
                                    index = index + 1;
                                end 
                            end
                        end
                    end
                end
            end
        end
    end
end

%---nine---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                    for k6 = k5 + 1 : size(contexts,2)
                        for k7 = k6 + 1 : size(contexts,2)
                            for k8 = k7 + 1 : size(contexts,2)
                                for k9 = k8 + 1 : size(contexts,2)
                                    temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                                        data.(contexts{k3}) + data.(contexts{k4}) + ...
                                        data.(contexts{k5}) + data.(contexts{k6}) + ...
                                        data.(contexts{k7}) + data.(contexts{k8}) + ...
                                        data.(contexts{k9});
                                    temp2 = unique(temp);
                                    temp2(isnan(temp2)) = [];
                                    for u = 1 : size(temp2,1)
                                        contextCount(index,1) = temp2(u);
                                        contextCount(index,2) = sum(temp == temp2(u));
                                        index = index + 1;
                                    end 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%---ten---
for k1 = 1 : size(contexts,2)
    for k2 = k1 + 1 : size(contexts,2)
        for k3 = k2 + 1 : size(contexts,2)
            for k4 = k3 + 1 : size(contexts,2)
                for k5 = k4 + 1 : size(contexts,2)
                    for k6 = k5 + 1 : size(contexts,2)
                        for k7 = k6 + 1 : size(contexts,2)
                            for k8 = k7 + 1 : size(contexts,2)
                                for k9 = k8 + 1 : size(contexts,2)
                                    for k10 = k9 + 1 : size(contexts,2)
                                        temp = data.(contexts{k1}) + data.(contexts{k2}) + ...
                                            data.(contexts{k3}) + data.(contexts{k4}) + ...
                                            data.(contexts{k5}) + data.(contexts{k6}) + ...
                                            data.(contexts{k7}) + data.(contexts{k8}) + ...
                                            data.(contexts{k9}) + data.(contexts{k10});
                                        temp2 = unique(temp);
                                        temp2(isnan(temp2)) = [];
                                        for u = 1 : size(temp2,1)
                                            contextCount(index,1) = temp2(u);
                                            contextCount(index,2) = sum(temp == temp2(u));
                                            index = index + 1;
                                        end 
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

clearvars temp;

contextCount = flipud(sortrows(contextCount,2));
contextCount(:,3) = contextCount(:,2) / size(data,1);

%convert context num to string
contextCountStr = num2str(contextCount);
for k = 1 : size(contextCount,1)
    tempStr = '';
    for j = 1 : 10
        if str2double(contextCountStr(k,j)) ~= 0 && ~strcmp(contextCountStr(k,j),' ')
            tempStr = strcat(tempStr,strcat(strcat(contexts2{j},num2str(contextCountStr(k,j))),','));
        end
    end
    if size(tempStr,2) == 0
        tempStr = strcat('CND',num2str(contextCountStr(k,10:11))); 
    elseif ~strcmp(num2str(contextCountStr(k,10:11)),'00')
        tempStr =  strcat(tempStr,(strcat('CND',num2str(contextCountStr(k,10:11)))));
    end
    
    temp(k) = cellstr(tempStr);
end
contextCount2 = table;
contextCount2.contextSubset = contextCount(:,1);
contextCount2.contextSubset2 = temp';
contextCount2.numInDataSet = contextCount(:,2);
contextCount2.prob = contextCount(:,3);

%find subsets
for k = 1 : size(contextCount,1)
    temp = num2str(contextCount(k,1)); 
    index = 0;
    for j = 1 : size(temp,2)
        if strcmp(temp(j),'9') && j < size(temp,2)
            temp(j)
            continue;
        elseif ~strcmp(temp(j),' ') && ~strcmp(temp(j),'0')
            index = index + 1; 
        end
    end
    contextSize(k) = index;
end
contextSubsetSize1 = contextCount2(contextSize == 1,:);
contextSubsetSize2 = contextCount2(contextSize == 2,:);
contextSubsetSize3 = contextCount2(contextSize == 3,:);
contextSubsetSize4 = contextCount2(contextSize == 4,:);
contextSubsetSize5 = contextCount2(contextSize == 5,:);
contextSubsetSize6 = contextCount2(contextSize == 6,:);
contextSubsetSize7 = contextCount2(contextSize == 7,:);
contextSubsetSize8 = contextCount2(contextSize == 8,:);
contextSubsetSize9 = contextCount2(contextSize == 9,:);
contextSubsetSize10 = contextCount2(contextSize == 10,:);

save('contextCountAndProb','contextCount2','contextSubsetSize1','contextSubsetSize2','contextSubsetSize3',...
    'contextSubsetSize4','contextSubsetSize5','contextSubsetSize6','contextSubsetSize7','contextSubsetSize8',...
    'contextSubsetSize9','contextSubsetSize10');
