%Ryan Brummet
%University of Iowa

function [ extractedData ] = trimData( data, threshold )
    %data will be in the form Patient, listening, userInit, ac, lc,
    %       tf, vc, tl, nl, rs, cp, nz, condition, sp, le, ld, ld2, lcl, ap, qol, im, 
    %       st

    %Any values that are greater than STD*threshold are considered outliers and removed.
    
    for k = 1 : 9
        STD(k) = nanstd(data(:,13 + k));
        avg(k) = nanmean(data(:,13 + k));
    end
    
    index = 1;
    count = true;
    for k = 1 : size(data,1)
        for j = 1 : 9
            if avg(j) + STD(j)*threshold < data(k,13 + j) || ...
                    avg(j) - STD(j)*threshold > data(k,13 + j)
                count = false;
            end
        end
        if count
            extractedData(index,:) = data(k,:);
            index = index + 1;
        end
        count = true;
    end
end

