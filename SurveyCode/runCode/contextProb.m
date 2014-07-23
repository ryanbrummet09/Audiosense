clear;
clc;

load('compositeScoreOn_NoMap_UsingSUMADJRNoNorm.mat');
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
        tempStr = strcat('CND',num2str(contextCountStr(k,11))); 
    end
    tempStr = tempStr(1,1:size(tempStr,2) - 1);
    temp(k) = cellstr(tempStr);
end
contextCount2 = table;
contextCount2.contextSubset = temp';
contextCount2.numInDataSet = contextCount(:,2);
contextCount2.prob = contextCount(:,3);
save('contextCountAndProb','contextCount');
%save('contextCountAndProb','contextCount');
