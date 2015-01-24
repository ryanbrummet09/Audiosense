function [ perPatientStruct ] = createPerPatientTable( ipDataset, ...
                                minSamples, patientsToLookAt)
%CREATEPERPATIENTTABLE Create per patient tables
%   Input:
%           ipDataset       :       Table to be worked upon
%           minSamples      :       Minimum number of samples that a
%                                   patient should have to be included in
%                                   the output, default = 10
%           patientsToLookAt:       Patients to include in the final output
%   
%   Output:
%           perPatientStruct:       Structure containing per patient data,
%                                   each patient is identified by
%                                   patient_<patientID> field

if 1 == nargin
    minSamples = 10;
    patientsToLookAt = unique(ipDataset.patient);
elseif 2 == nargin
    patientsToLookAt = unique(ipDataset.patient);
end

perPatientStruct = struct;

for P=1:length(patientsToLookAt)
    pTable = ipDataset(ipDataset.patient == patientsToLookAt(P),:);
    if minSamples > height(pTable)
        disp(sprintf('Patient %d has %d samples, removing', ...
                patientsToLookAt(P), height(pTable)));
        continue;
    else
        perPatientStruct.(sprintf('patient_%d',patientsToLookAt(P))) = ...
                                pTable;
    end
end

end

