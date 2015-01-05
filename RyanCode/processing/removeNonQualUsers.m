%Ryan Brummet
%University of Iowa

function [ dataTable ] = removeNonQualUsers( dataTable, minSamples )
    %dataTable: table containing patient data
    
    %minSample: minimum number of samples a user must have in order for
    %           that user to have samples in the data set. 
    
    subjectIDs = unique(dataTable.patient);
    for k = 1 : size(subjectIDs)
        indexes = (dataTable.patient == subjectIDs(k));
        if sum(indexes) < minSamples
            dataTable(indexes,:) = [];
        end
    end
end

