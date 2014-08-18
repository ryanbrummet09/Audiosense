%% initialize
clear;
close all;
clc;

target = 'NoMap';
norm = 'NoNorm';  %can be NoNorm, GlobalNorm, or UserNorm
combineTech = 'SUMADJR'; %can be AVG, SUM, MEDIAN, STD
dataFileName = char(strcat('/Users/ryanbrummet/Documents/MATLAB/Audiology/compositeScores/compositeScoreOn_',target,'_Using',combineTech,norm,'.mat'));
usedContexts = {'ac', 'lc', 'tf', 'vc', 'tl', 'nl', 'rs', 'cp', 'nz', 'condition'};
indvContexts = {'ac1','ac2','ac3','ac4','ac5','ac6','ac7','lc1','lc2', ...
    'lc3','lc4','lc5','tf1','tf2','tf3','tf4','tfNaN','vc1','vc2','vc3', ...
    'vcNaN','tl1','tl2','tl3','tlNaN','nl1','nl2','nl3','nl4','nlNaN','rs1','rs2', ...
    'rs3','rsNaN','cp1','cp2','cpNaN','nz1','nz2','nz3','nz4','condition0', ...
    'condition1','condition2','condition3','condition4','condition5','condition99'};

labelContext = {'ac1','ac2','ac3','ac4','ac5','ac6','ac7','lc1','lc2', ...
    'lc3','lc4','lc5','tf1','tf2','tf3','tf4','tf0','vc1','vc2','vc3', ...
    'vc0','tl1','tl2','tl3','tl0','nl1','nl2','nl3','nl4','nl0','rs1','rs2', ...
    'rs3','rs0','cp1','cp2','cp0','nz1','nz2','nz3','nz4','cd0', ...
    'cd1','cd2','cd3','cd4','cd5','cd99'};
%contextAmounts = [7,5,4,3,3,4,3,2,4,7];

%% load data
load(dataFileName);
data = [trainingSet;validationSet];

%% Count the occurances of each context element and find prob
for k = 1 : size(indvContexts,2)
    contextElementCount.(indvContexts{k}) = 0;
end

count = 0;
for k = 1 : size(data,1)
    for j = 1 : size(usedContexts,2)
        tempString = strcat(usedContexts{j},num2str(data.(usedContexts{j})(k)));
        contextElementCount.(tempString) = contextElementCount.(tempString) + 1;
        count = count + 1;
    end
end

for k = 1 : size(indvContexts,2)
    contextElementProb.(indvContexts{k}) = contextElementCount.(indvContexts{k}) / count; 
end

%% Find huffman dict
huffmanDictTemp = huffmandict(indvContexts,struct2array(contextElementProb));

%find the proper depth
levels = 0;
for k = 1 : size(huffmanDictTemp,1)
    if size(cell2mat(huffmanDictTemp(k,2)),2) > levels
        levels = size(cell2mat(huffmanDictTemp(k,2)),2);
    end
end

% for k = 1 : size(huffmanDictTemp,1)
%     huffmanDict(k,1) = huffmanDictTemp(k,1);
%     temp1 = cell2mat(huffmanDictTemp(k,2));
%     temp1 = [temp1 zeros(1,levels - size(cell2mat(huffmanDictTemp(k,2)),2))];
%     temp2 = temp1(1,1:size(temp1,2) - 1);
%     temp3 = 1;
%     for j = 0 : size(temp2,2) - 1
%        if temp1(1,j + 1) == 0
%            temp3 = temp3 + 1; 
%        else
%            temp3 = temp3 + 2^(levels - j);
%        end
%     end
%     huffmanDict{k,2} = temp3;
% end

for k = 1 : size(huffmanDictTemp,1)
    huffmanDict(k,1) = huffmanDictTemp(k,1);
    temp1 = cell2mat(huffmanDictTemp(k,2));
    temp2 = 1;
    for j = 0 : size(temp1,2) - 1
        if j == size(temp1,2) - 1
            if j < levels - 1 && temp1(j + 1) == 1
                temp2 = temp2 + 2^(levels - j); 
            end
        else
            if temp1(1,j + 1) == 0
                temp2 = temp2 + 1; 
            else
                temp2 = temp2 + 2^(levels - j);
            end
        end
        
    end
    huffmanDict{k,2} = temp2;
end
 
huffmanDict(:,3) = cellfun(@(x) num2str(x,'%1d'), huffmanDictTemp(:,2),'uni',0);

%% Build tree of the proper depth
%find the number of nodes in the raw graph
numNodes = 0;
for k = 0 : levels
    numNodes = numNodes + 2^k;
end

tree = zeros(numNodes,1);
binVector = zeros(1,levels);
currentLevel = 1;

%build the tree vector
tree(1) = 0;
for k = 2 : numNodes
    if k ~= numNodes
        if currentLevel == 1
            tree(k) = 1; 
        else
            temp2 = binVector(1,1:currentLevel - 1);
            temp3 = 1;
            for j = 0 : size(temp2,2) - 1
                if binVector(1,j + 1) == 0
                    temp3 = temp3 + 1; 
                else
                    temp3 = temp3 + 2^(levels - j);
                end
            end
            tree(k) = temp3;
        end
        if currentLevel == levels
            if binVector(1,currentLevel) == 1
                binVector = fliplr(de2bi(bi2de(fliplr(binVector)) + 1,size(binVector,2)));
                while binVector(1,currentLevel) == 0
                    currentLevel = currentLevel - 1; 
                end
            else
                binVector = fliplr(de2bi(bi2de(fliplr(binVector)) + 1,size(binVector,2)));
            end
        else
            currentLevel = currentLevel + 1; 
        end
    else
        temp2 = binVector(1,1:currentLevel - 1);
        temp3 = 1;
        for j = 0 : size(temp2,2) - 1
            if binVector(1,j + 1) == 0
                temp3 = temp3 + 1; 
            else
                temp3 = temp3 + 2^(levels - j);
            end
        end
        tree(k) = temp3;
    end
end

%trim the tree to only include leaves that go to contexts
[huffmanDict,rowIndexes] = sortrows(huffmanDict,2);
huffmanDictTemp = huffmanDictTemp(rowIndexes,:);
labelContext = labelContext(:,rowIndexes)';
for k = 1 : size(huffmanDict,1)
    if k ~= size(huffmanDict,1)
        treeIndexLeft = find(huffmanDict{k,2} == tree);
        treeIndexRight = find(huffmanDict{k+1,2} == tree);
        if k == 1
            treeIndexLeft = treeIndexLeft(1);
            if huffmanDict{k,2} == huffmanDict{k+1,2}
                treeIndexRight = treeIndexRight(2); 
            else
                treeIndexRight = treeIndexRight(1);
            end
        else
            if huffmanDict{k,2} == huffmanDict{k+1,2}
                treeIndexLeft = treeIndexLeft(1);
                treeIndexRight = treeIndexRight(2);
            elseif huffmanDict{k,2} == huffmanDict{k-1,2}
                treeIndexLeft = treeIndexLeft(2);
                treeIndexRight = treeIndexRight(1);
            else
                treeIndexLeft = treeIndexLeft(1);
                treeIndexRight = treeIndexRight(1);
            end
        end
        if treeIndexRight - treeIndexLeft == 1
            continue; 
        end
        temp = find(huffmanDict{k,2} > tree(treeIndexLeft:treeIndexRight));
        if ~isempty(temp)
            treeIndexRight = temp(min(tree(temp + treeIndexLeft - 1)) == tree(temp + treeIndexLeft - 1)) + treeIndexLeft - 1; 
            if treeIndexRight - treeIndexLeft == 1
                continue; 
            end
            temp1 = (tree(treeIndexRight:size(tree,1)) > min(tree(temp + treeIndexLeft - 1)));
            temp2 = tree(treeIndexRight:size(tree,1));
            temp2(temp1) = temp2(temp1) - (treeIndexRight - treeIndexLeft - 1);
            tree(treeIndexRight:size(tree,1)) = temp2; 
        else
            temp = find(huffmanDict{k,2} == tree(treeIndexLeft:treeIndexRight));
            if ~isempty(temp)
                treeIndexMid = temp(2) + treeIndexLeft - 1;
                %here we need to start at treeIndexRight and work our way
                %back to treeIndexMid, finding which indexes to keep and
                %which to remove
                if treeIndexMid ~= treeIndexRight
                    current = treeIndexRight;
                    keepIndex = 1;
                    while current ~= treeIndexMid
                        toKeep(keepIndex) = current;
                        current = tree(current);
                        keepIndex = keepIndex + 1;
                    end
                    toKeep(keepIndex) = current;
                    toKeep = fliplr(toKeep);
                    keepIndex = 1;
                    for j = treeIndexMid : treeIndexRight
                        if sum(j == toKeep) == 0
                            temp1 = (tree(j:size(tree,1)) > tree(j));
                            temp2 = tree(j:size(tree,1));
                            temp2(temp1) = temp2(temp1) - 1;
                            tree(j:size(tree,1)) = temp2;
                            for h = k + 1 : size(huffmanDict,1)
                                if huffmanDict{h,2} >= tree(j)
                                    huffmanDict{h,2} = huffmanDict{h,2} - 1;
                                end
                            end
                            tree(j) = [];
                            toKeep = toKeep - 1;
                            keepIndex = keepIndex + 1;
                        end
                    end
                    clearvars toKeep;
                    treeIndexRight = treeIndexMid;
                end
                
                if treeIndexRight - treeIndexLeft == 1
                    continue; 
                end
                if treeIndexRight - treeIndexLeft ~= 1
                    temp1 = (tree(treeIndexRight:size(tree,1)) > tree(treeIndexLeft));
                    temp2 = tree(treeIndexRight:size(tree,1));
                    temp2(temp1) = temp2(temp1) - (treeIndexRight - treeIndexLeft - 1);
                    tree(treeIndexRight:size(tree,1)) = temp2;
                end
            end
        end
        for j = k + 1 : size(huffmanDict,1)
            if huffmanDict{j,2} >= min(tree(temp + treeIndexLeft - 1))
                huffmanDict{j,2} = huffmanDict{j,2} - (treeIndexRight - treeIndexLeft - 1); 
            end
        end
        tree(treeIndexLeft + 1:treeIndexRight - 1) = [];
    else
        if huffmanDict{k,2} + 1 < size(tree,1)
            tree(huffmanDict{k,2} + 1:size(tree,1)) = [];
        end
    end
end


%% Remove inner nodes that were missplaced
for k = 1 : size(huffmanDictTemp,1) - 1
    huffSize = size(cell2mat(huffmanDictTemp(k,2)),2);
    current = huffmanDict{k,2};
    count = 0;
    keepIndex = 1;
    while current ~= 0
        toKeep(keepIndex) = current;
        current = tree(current);
        keepIndex = keepIndex + 1;
    end
    if size(toKeep,2) ~= huffSize;
        removeIndex = find(toKeep(1) == tree);
        temp1 = (tree(removeIndex:size(tree,1)) > tree(removeIndex));
        temp2 = tree(removeIndex:size(tree,1));
        temp2(temp1) = temp2(temp1) - 1;
        tree(removeIndex:size(tree,1)) = temp2;
        for j = k + 1 : size(huffmanDict,1)
            if huffmanDict{j,2} >= tree(removeIndex)
                huffmanDict{j,2} = huffmanDict{j,2} - 1; 
            end
        end
        tree(removeIndex) = [];
    end
    clearvars toKeep;
end

%% Plot the tree, find the locations of the leafs, and add labels
% for k = 1 : size(huffmanDict,1)
%     huffmanDict{k,2} = tree(huffmanDict{k,2}); 
% end
treeplot(tree');

[xVals,yVals] = treelayout(tree');
xVals = xVals';
yVals = yVals';

labelIndexes = find(min(yVals) == yVals);

count = size(labelIndexes,1);
name1 = cellstr(num2str((1:count)'));
text(xVals(labelIndexes,1), yVals(labelIndexes,1), cellstr(labelContext), 'VerticalAlignment','top','HorizontalAlignment','right')
title({'Huffman Encoding Graph'},'FontSize',5,'FontName','Times New Roman');

