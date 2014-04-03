function [ tp, fn, fp ] = tpFNfp( actual, found,debugType )
%TPFNFP returns the true positive, false negative and false positive
%   For a particular file, this returns the true positive, false negative
%   and false positive frequencies of the buzz and beep removals.
%
%   Input: (actual, found, debugType)
%   acutal          :           the actual locations of buzz or beep
%   found           :           the locations found by the algorithm
%   debugType       :           'bz' for buzz or 'bp' for beep
%
%
%   Output: [tp, fn,fp]
%   tp              :           True Positives
%   fn              :           False Negatives
%   fp              :           False Positives
addpath ../../;
addpath ../../voicebox;
addpath ../../preprocess;
tp = 0;
fn = 0;
found(:,end+1) = 1;
% find the TP and FN
[found_n,idk] = size(found);
%disp('Length of found_n');
%disp(found_n);
for N = 1:length(actual)
    v = actual(N);
    foundIt = false;
    for M = 1:found_n
        %s = sprintf('Checking %f between %f and %f in %s',v,found(M,1),found(M,2),debugType);
%         disp(s);
        if v <= found(M,2) & v >= found(M,1)
            foundIt = true;
            s = sprintf('Actual: %f, between %f and %f, debug: %s',v,found(M,1),found(M,2),debugType);
            disp(s);
            found(M,3) = 0;
            break;
        else
            continue;
        end
    end
    if foundIt
        tp = tp + 1;
    else
        fn = fn + 1;
    end
end
fp = sum(found(:,3));
end

