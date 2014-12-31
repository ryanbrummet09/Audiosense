function [ features, labels, minMaxV ] = getSVMArrays( ipDataset, ...
                            outcomeMeasure, patientDummy, ...
                            conditionDummy, minMaxV, toInclude) 
%GETSVMARRAYS Summary of this function goes here
%   Detailed explanation goes here
minMax = true;
if 5 == nargin
    toInclude = {'zcr','rmsV','entropy','srf','mfcc0','mfcc1',...
        'mfcc2','mfcc3','mfcc4','mfcc5','mfcc6','mfcc7',...
        'mfcc8','mfcc9','mfcc10','mfcc11','mfcc12'};
elseif 4 ==  nargin
    minMaxV = [];
    minMax = false;
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
temp = [];
for P=1:n
    temp = [temp eval(sprintf('ipDataset.%s;',toInclude{P}))];
end
if minMax
    [temp, ~] = scaleValues(temp, 0, 1, minMaxV);
else
    [temp, minMaxV] = scaleValues(temp, 0, 1);
end
features = [features temp];
end

