function [ accMat, bestMeasures ] = learnBestModel( ipStructure, ...
                                    outcomeMeasure, cRange, epRange, k)
%LEARNBESTMODEL give the configuration that yields the lowest mse
%   Detailed explanation goes here
if 4 == nargin
    k = 5;
end

bestMeasures = struct;
bestMeasures.mse = inf;
bestMeasures.c = -1;
bestMeasures.e = -1;
bestMeasures.k = -1;
accMat = zeros(length(cRange), length(epRange), k);
addpath ../;
addpath ./libsvm-3.20/matlab/;
%parObj = parpool;
for P=1:k
    eval(sprintf('pD = ipStructure.%s.partition.dummyEncMapping.patient;',outcomeMeasure));
    eval(sprintf('cD = ipStructure.%s.partition.dummyEncMapping.condition;',outcomeMeasure));
    eval(sprintf('trainingTable = ipStructure.%s.partition.folds.fold%d.trainingSet;',outcomeMeasure, P));
    eval(sprintf('validationTable = ipStructure.%s.partition.folds.fold%d.validationSet;',outcomeMeasure, P));
    [feature_train, label_train] = getSVMArrays(trainingTable, ...
                                    outcomeMeasure, pD, cD);
    [feature_valid, label_valid] = getSVMArrays(validationTable, ...
                                    outcomeMeasure, pD, cD);                            
    for Q = 1:length(cRange)
        for R = 1:length(epRange)
            model = svmtrain(label_train, feature_train, ...
                sprintf('-s 3 -t 0 -c %f -p %f -h 0',cRange(Q), epRange(R)));
            [~, acc, ~] = svmpredict(label_valid, feature_valid, model);
            accMat(Q,R,P) = acc(2);
        end
    end
    tempMat = accMat(:,:,P);
    mV = min(min(tempMat));
    if mV < bestMeasures.mse
        [rm, cm] = find(tempMat == mV);
        bestMeasures.mse = mV;
        bestMeasures.c = cRange(rm);
        bestMeasures.e = epRange(cm);
        bestMeasures.k = P;
    end
end
%delete(parObj);
end

