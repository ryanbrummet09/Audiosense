function highLeveLPreprocess_labelVector( fileStruct )
%HIGHLEVELPREPROCESS_LABELVECTOR Summary of this function goes here
%   This function extracts high level features from the files on the
%   specificied size window size.
%       Input:
%               fileStruct              :   This is a structure that 
%                                           contains several fields, 
%                                           each of which are described 
%                                           below
%               fileStruct.filename     :   name of file
%               fileStruct.frameLength  :   the length of the extracted
%                                           frames in seconds
%               fileStruct.windowLength :   the length of the window over
%                                           which the high level features
%                                           are calculated, this is also in
%                                           seconds. If the windowLength is
%                                           given to be 0 then the complete
%                                           file is considered.
%               fileStruct.folderToSave :   this is an optional field which
%                                           allows the user to specify
%                                           where to save the extracted
%                                           high level features
%               fileStruct.noOfMFCC     :   the total number of mfcc's
%                                           extracted
%               fileStruct.SRFs         :   the array containing the SRF
%                                           percentiles extracted
%               fileStruct.noOfSBP      :   the number of subband powers
%                                           extracted
%               fileStruct.labelOrder   :   the names of the actual labels
%                                           in the vector

featureTable = table;
if 0 < fileStruct.windowLength
    numberOfFrames = floor(fileStruct.windowLength/fileStruct.frameLength);
else
    numberOfFrames = -1;
end
if ~isfield(fileStruct,'folderToSave')
    fileStruct.folderToSave = './';
else
    if 7 ~= exist(fileStruct.folderToSave)
        mkdir(fileStruct.folderToSave);
    end
end
fname = fileStruct.filename;
actualFName = strsplit(fname,'/');
actualFName = actualFName{end};
actualFName = strsplit(actualFName,'.');
actualFName = actualFName{end};
actualFName = strsplit(actualFName,'_');
disp(sprintf('Working with %s',fname));
fdata = load(fname);
fdata = fdata.var;
if  isempty(fdata)
    disp('Empty');
    return;
end
dataStruct = struct;
[r,c] = size(fdata);
if -1 == numberOfFrames
    numberOfFrames = r;
end
numberOfLabels = length(fileStruct.labelOrder);
for Q = 1:numberOfFrames:r
    s = Q;
    e = Q+numberOfFrames;
    if e > r
        e = r;
    end
%         work with atleast 2 samples
    if 2 > e - s
        disp(sprintf('s:%d, e:%d, r:%d',s,e,r));
        continue;
    end
    dataStruct.pid = str2num(actualFName{1});
    dataStruct.cid = str2num(actualFName{2});
    dataStruct.sid = str2num(actualFName{3});
    dataStruct.date = actualFName{4};
    dataStruct.extras = true;
    dataStruct.mfcc = fileStruct.noOfMFCC;
    dataStruct.srf = fileStruct.SRFs;
    dataStruct.sbp = fileStruct.noOfSBP;
    dataStruct.label_name = fileStruct.labelOrder;
    dataStruct.features = fdata(s:e,1:end-numberOfLabels);
    dataStruct.label = fdata(s:e,end-numberOfLabels+1:end);
    tempTable = HigherLevelFeatures(dataStruct,true);
    featureTable = [featureTable; tempTable];
end
extraInformation = struct;
extraInformation.numberOfLabels = numberOfLabels;
extraInformation.toStartLookingFrom = 5;
featureTable = scaleTable(featureTable, extraInformation);
save(sprintf('%sfeatureTable_%s_%s_%s_%s_%d_%d',fileStruct.folderToSave,...
    actualFName{1},actualFName{2},actualFName{3},actualFName{4},...
    int32(fileStruct.frameLength*1000),...
    int32(fileStruct.windowLength*1000)),'featureTable');
end

