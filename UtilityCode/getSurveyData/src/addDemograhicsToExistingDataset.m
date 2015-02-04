function [ ipDataset ] = addDemograhicsToExistingDataset( ipDataset, ...
                            xlsFilePath)
%ADDDEMOGRAHICSTOEXISTINGDATASET Add demographics to existing dataset
%   Input:
%           ipDataset       :       dataset to which demographic data is to
%                                   be added
%           xlsFilePath     :       path to xls file containing demographic
%                                   data
% 
%   Output:
%           ipDataset       :       dataset with the demographics data
% 
%   SEE ALSO GETDEMOGRAPHICSDATA, GETSNRTESTDATA

demoData = getDemographicsData(xlsFilePath);
sinTest = getSNRTestData(xlsFilePath);
audiogramData = getDemographicAudiogram(xlsFilePath);
patientList = ipDataset.patient;
ageV = zeros(length(patientList),1);
snrLoss = zeros(length(patientList),2);
lowHigh = zeros(length(patientList),4);
for P=1:length(patientList)
    ageV(P) = demoData.age(demoData.patient == patientList(P));
    snrLoss(P,1) = sinTest.sinLeft(sinTest.patient == patientList(P));
    snrLoss(P,2) = sinTest.sinRight(sinTest.patient == patientList(P));
    lowHigh(P,1) = audiogramData.lowPTALeft(audiogramData.patient == ...
                                            patientList(P));
    lowHigh(P,2) = audiogramData.highPTALeft(audiogramData.patient == ...
                                            patientList(P));
    lowHigh(P,3) = audiogramData.lowPTARight(audiogramData.patient == ...
                                            patientList(P));
    lowHigh(P,4) = audiogramData.highPTARight(audiogramData.patient == ...
                                            patientList(P));
end
ipDataset.age = ageV;
ipDataset.snrLeft = snrLoss(:,1);
ipDataset.snrRight = snrLoss(:,2);
ipDataset.lowPTALeft = lowHigh(:,1);
ipDataset.highPTALeft = lowHigh(:,2);
ipDataset.lowPTARight = lowHigh(:,3);
ipDataset.highPTARight = lowHigh(:,4);
end

