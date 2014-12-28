function [ partition ] = createPartitions( ipDataset, rng_seed, k )
%CREATEPARTITIONS Summary of this function goes here
%   Detailed explanation goes here

if 2 == nargin
    k = 5;
end

partition = struct;
rng(rng_seed);
pids = ipDataset.patient;
cids = ipDataset.condition;
[~, dE_p] = dummyEnc(pids);
[~, dE_c] = dummyEnc(cids);
partition.dummyEncMapping.patient = dE_p;
partition.dummyEncMapping.condition = dE_c;
cvP = cvpartition(ipDataset.patientCondition, 'holdout', 0.2);
partition.main.cv = cvP;
mainTrain = ipDataset(training(cvP),:);
partition.main.trainingSet = mainTrain;
partition.main.testingSet = ipDataset(test(cvP),:);
cvP = cvpartition(mainTrain.patientCondition, 'kfold', k);
partition.folds.cv = cvP;
for P=1:k
    fld_tr = mainTrain(training(cvP,P),:);
    fld_vd = mainTrain(test(cvP,P),:);
    eval(sprintf('partition.folds.fold%d.trainingSet = fld_tr;',P));
    eval(sprintf('partition.folds.fold%d.validationSet = fld_vd;',P));
end

end

