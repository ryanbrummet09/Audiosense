function [ accTable, bestMeasures ] = learnBestModel_rbf( ipStructure, ...
                                    outcomeMeasure, cRange, epRange, ...
                                    gRange, k )
%LEARNBESTMODEL_RBF Summary of this function goes here
%   Detailed explanation goes here
if 5 == nargin
    k = 5;
end

bestMeasures = struct;
accTable = table;
firstTime = true;
addpath ../;
addpath ./libsvm-3.20/matlab/;
for P=1:k
    disp(sprintf('fold %d',P));
    eval(sprintf('pD = ipStructure.%s.partition.dummyEncMapping.patient;',outcomeMeasure));
    eval(sprintf('cD = ipStructure.%s.partition.dummyEncMapping.condition;',outcomeMeasure));
    eval(sprintf('trainingTable = ipStructure.%s.partition.folds.fold%d.trainingSet;',outcomeMeasure, P));
    eval(sprintf('validationTable = ipStructure.%s.partition.folds.fold%d.validationSet;',outcomeMeasure, P));
    [feature_train, label_train] = getSVMArrays(trainingTable, ...
                                    outcomeMeasure, pD, cD);
    [feature_valid, label_valid] = getSVMArrays(validationTable, ...
                                    outcomeMeasure, pD, cD); 
    for Q = 1:length(cRange)
        for R = 1:length(gRange)
            for S = 1:length(epRange)
                model = svmtrain(label_train, feature_train, ...
                sprintf('-s 3 -t 2 -c %f -g %f -p %f -h 0 -q',cRange(Q), ...
                gRange(R), epRange(S)));
                [~, acc, ~] = svmpredict(label_valid, feature_valid, model);
                temp = [P cRange(Q) gRange(R) epRange(S) acc(2)];
                if firstTime
                    accTable = array2table(temp);
                    accTable.Properties.VariableNames = {'fold','c',...
                                                        'g', 'e', 'mse'};
                    firstTime = false;
                else
                    temp = array2table(temp);
                    temp.Properties.VariableNames = {'fold','c',...
                                                     'g', 'e', 'mse'};
                    accTable = [accTable; temp];
                end
            end
        end
    end
end
temp = min(accTable.mse);
tempT = accTable(accTable.mse == temp,:);
bestMeasures.mse = tempT.mse;
bestMeasures.c = tempT.c;
bestMeasures.g = tempT.g;
bestMeasures.e = tempT.e;
bestMeasures.fold = tempT.fold;
end

