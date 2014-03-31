function [ specs ] = specSen( buzzBeep, toCheck )
%SPECSEN Checks the validity of the buzz and beep removal
%   This takes as input the buzz and beeps found manually and compares them
%   with the ones found by the code of REMOVE_BUZZ, REMOVE_BEEP. The output
%   is a matrix where each row is:
%   [patient ID, condition ID, session ID, tp_beep, fn_beep, fp_beep,
%   tp_buzz, fn_buzz, fp_buzz, recall_beep, recall_buzz, precision_beep,
%   recall_buzz]
%   Here    tp = true positives
%           fn = false negatives
%           fp = false positives

specs = [];
for P = 1:length(toCheck)
    pcs = toCheck{P,1};
    pcs
    actualBeep = toCheck{P,2};
    %disp('AB');
    %actualBeep
    actualBuzz = toCheck{P,3};
    %disp('AZ');
    %actualBuzz
    for Q = 1:length(buzzBeep)
        if isequal(pcs,buzzBeep{Q,1})
            foundBeep = buzzBeep{Q,2};
            foundBuzz = buzzBeep{Q,3};
            [tp_p,fn_p,fp_p] = tpFNfp(actualBeep,foundBeep,'bp');
            [tp_z,fn_z,fp_z] = tpFNfp(actualBuzz,foundBuzz,'bz');
            specs(end+1,:) = [pcs(1),pcs(2),pcs(3),tp_p,fn_p,fp_p,tp_z,fn_z,fp_z,-1,-1,-1,-1];
        end
    end

end

for P = 1:length(specs)
    specs(P,10) = specs(P,4)./(specs(P,4) + specs(P,5));
    specs(P,11) = specs(P,7)./(specs(P,7) + specs(P,8));
    specs(P,12) = specs(P,4)./(specs(P,4) + specs(P,6));
    specs(P,13) = specs(P,7)./(specs(P,7) + specs(P,9));
end
end

