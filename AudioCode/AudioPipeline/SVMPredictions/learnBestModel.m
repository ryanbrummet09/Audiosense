function [ accMat, bestMeasures ] = learnBestModel( ipStructure, ...
                                    outcomeMeasure, cRange, epRange, k)
%LEARNBESTMODEL give the configuration that yields the lowest mae
%   Detailed explanation goes here
if 4 == nargin
    k = 5;
end

bestMeasures = struct;
bestMeasures.mae = inf;
bestMeasures.c = -1;
bestMeasures.e = -1;
tempMat = zeros(length(cRange), length(epRange));
accMat = zeros(length(cRange), length(epRange), k);
addpath ../;
addpath ./libsvm-3.20/matlab/;
for P=1:k
    eval(sprintf('pD = ipStructure.%s.partition.dummyEncMapping.patient;',outcomeMeasure));
    eval(sprintf('cD = ipStructure.%s.partition.dummyEncMapping.condition;',outcomeMeasure));
    eval(sprintf('trainingTable = ipStructure.%s.partition.folds.fold%d.trainingSet;',outcomeMeasure, P));
    eval(sprintf('validationTable = ipStructure.%s.partition.folds.fold%d.validationSet;',outcomeMeasure, P));
    [feature_train, label_train, minMaxV] = getSVMArrays(trainingTable, ...
                                    outcomeMeasure, pD, cD);
    [feature_valid, label_valid, ~] = getSVMArrays(validationTable, ...
                                    outcomeMeasure, pD, cD, minMaxV);                            
    for Q = 1:length(cRange)
        for R = 1:length(epRange)
            model = svmtrain(label_train, feature_train, ...
                sprintf('-s 3 -t 0 -c %f -p %f -h 0',cRange(Q), epRange(R)));
            [yHat, ~, ~] = svmpredict(label_valid, feature_valid, model);
            yHat(yHat<0) = 0;
            yHat(yHat>100) = 100;
            meanAbsError = mean(abs(yHat - label_valid));
            accMat(Q,R,P) = meanAbsError;
        end
    end
    tempMat = tempMat + accMat(:,:,P);
end
[r,c] = find(tempMat == min(min(tempMat)));
bestMeasures.mae = min(min(tempMat))/k;
bestMeasures.c = cRange(r);
bestMeasures.e = epRange(c);
end

