function [ partition ] = createPartitions( ipDataset, rng_seed, k )
%CREATEPARTITIONS Creates inner and outer folds
%   Input:
%           ipDataset   :   input dataset for particular outcome
%           rng_seed    :   seed for the random number generator
%           k           :   number of inner and outer folds
% 
%
%   Output:
%           partition   :   structure containing outer folds, cvpartitions,
%                           inner folds

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
cvP = cvpartition(ipDataset.patientCondition, 'kfold', k);
partition.folds.cv = cvP;
for P=1:k
    trSOuter = ipDataset(training(cvP,P),:);
    tsSOuter = ipDataset(test(cvP,P),:);
    eval(sprintf('partition.folds.fold%d.trainingSet = trSOuter;',P));
    eval(sprintf('partition.folds.fold%d.testingSet = tsSOuter;',P));
    innerCVP = cvpartition(trSOuter.patientCondition, 'kfold', k);
    eval(sprintf('partition.folds.fold%d.cv = innerCVP;',P));
    for Q=1:k
        inTr = trSOuter(training(innerCVP,Q),:);
        inTs = trSOuter(test(innerCVP,Q),:);
        eval(sprintf('partition.folds.fold%d.folds%d.trainingSet = inTr;',P,Q));
        eval(sprintf('partition.folds.fold%d.folds%d.validationSet = inTs;',P,Q));
    end
end
end

