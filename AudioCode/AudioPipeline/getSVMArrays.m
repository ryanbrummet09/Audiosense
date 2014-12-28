function [ features, labels ] = getSVMArrays( ipDataset, outcomeMeasure,...
                            patientDummy, conditionDummy, toInclude )
%GETSVMARRAYS Summary of this function goes here
%   Detailed explanation goes here
if 4 == nargin
    toInclude = {'zcr','rmsV','entropy','srf','mfcc0','mfcc1',...
        'mfcc2','mfcc3','mfcc4','mfcc5','mfcc6','mfcc7',...
        'mfcc8','mfcc9','mfcc10','mfcc11','mfcc12'};
end
pids = ipDataset.patient;
cids = ipDataset.condition;
[pD, ~] = dummyEnc(pids, patientDummy);
[cD, ~] = dummyEnc(cids, conditionDummy);
labels = eval(sprintf('ipDataset.%s;',outcomeMeasure));

n = length(toInclude);
features = [pD cD];
for P=1:n
    temp = eval(sprintf('ipDataset.%s;',toInclude{P}));
    features = [features temp];
end

