function highLevelPreprocess( fileStruct )
%HIGHLEVELPREPROCESS extracts high level features of specified sized window
%   This function extracts high level features from the files on the
%   specificied size window size.
%       Input:
%               fileStruct              :   This is a structure that 
%                                           contains several fields, 
%                                           each of which are described 
%                                           below
%               fileStruct.featureFileList: the list of feature files
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
featureTable = table;
k=0;
x=1;
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
for P=1:length(fileStruct.featureFileList)
%     get the file name, the details of the label etc out
    fname = fileStruct.featureFileList{P};
    actualFName = strsplit(fname,'/');
    actualFName = actualFName{end};
    disp(sprintf('Working with %s',actualFName));
    actualFName = strsplit(actualFName,'.');
    actualFName = actualFName{1};
    actualFName = strsplit(actualFName,'_');
    fdata = load(fname);
    fdata = fdata.var;
    if isempty(fdata)
        disp('Empty!');
        continue;
    end
    dataStruct = struct;
    [r,c] = size(fdata);
    if 0 == fileStruct.windowLength
        numberOfFrames = r;
    end
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
        dataStruct.features = fdata(s:e,:);
        dataStruct.pid = str2num(actualFName{1});
        dataStruct.cid = str2num(actualFName{2});
        dataStruct.sid = str2num(actualFName{3});
        dataStruct.label = actualFName{4};
        if strcmp('media',dataStruct.label)
            dataStruct.label = strcat(actualFName{4},'_',actualFName{5});
        end
        tempTable = HigherLevelFeatures(dataStruct);
        featureTable = [featureTable; tempTable];
    end
end
featureTable = scaleTable(featureTable);
save(sprintf('%sfeatureTable',fileStruct.folderToSave),'featureTable');
end

