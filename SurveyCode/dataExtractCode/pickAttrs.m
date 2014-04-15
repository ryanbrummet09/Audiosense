%Author Ryan Brummet
%University of Iowa

function [ outputData, newTarget ] = pickAttrs( inputData, targetAttrs, ... 
    attrMapTarget )

%  inputData (input matrix): gives the data that was extracted. 
%       This matrix is in the form patientID, listening, userInit, ac, lc, tf, vc,
%       tl, nl, rs, cp, nz, condition, sp, le, ld, ld2, lcl, ap, qol, im,
%       st.  If values attributes were removed the column identities are
%       subject to change.  Removing attributes has the effect of deleting
%       columns so the indexes will be effected by which columns are
%       deleted.

%  targetAtts (input vector): a 1x9 vector of 1s and 0s.  Each column stands
%       for, in increasing index size, sp, le, ld, ld2, lcl, ap, qol, im,
%       st.  A 1 indicates to extract the attribute, a 0 indicates not to
%       extract the attribute.  true or false may be used in place of the
%       1s and 0s.

%  attrMapTarget (input int): gives the attribute that all attributes will be
%       mapped onto.  1 for sp, 2 for le, 3 for ld, 4 for ld2, 5 for lcl, 6 for
%       ap, 7 for qol, 8 for im, 9 for st.  We must adjust this value if we
%       remove attributes.

%  ouputData (output matrix): the inputData matrix with attribute columns
%       removed based on the variable targetAtts.

    
    if ~targetAttrs(1,attrMapTarget)
       error('You cannot remove an attribute then map to it'); 
    end
    
    newTarget = attrMapTarget;
    
    index = 0;
    for k = 1 : 9
        if ~targetAttrs(1,k)
            inputData(:,13 + k - index) = []; 
            index = index + 1;
            if newTarget + index > k
                newTarget = newTarget - 1;
            end
        end
    end
    outputData = inputData;
end

