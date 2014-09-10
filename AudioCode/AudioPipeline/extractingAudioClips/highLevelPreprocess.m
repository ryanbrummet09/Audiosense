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
%                                           seconds
%               fileStruct.folderToSave :   this is an optional field which
%                                           allows the user to specify
%                                           where to save the extracted
%                                           high level features
featureTable = table;
k=0;
x=1;
numberOfFrames = floor(fileStruct.windowLength/fileStruct.frameLength);
if ~isfield(fileStruct,'folderToSave')
    fileStruct.folderToSave = './';
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
    for Q = 1:numberOfFrames:r
        s = Q;
        e = Q+numberOfFrames;
        if e > r
            e = r;
        end
        dataStruct.data = fdata(s:e,:);
        dataStruct.pid = str2num(actualFName{1});
        dataStruct.cid = str2num(actualFName{2});
        dataStruct.sid = str2num(actualFName{3});
        dataStruct.sno = str2num(actualFName{4});
        dataStruct.label = actualFName{5};
        tempTable = HigherLevelFeatures(dataStruct);
        k = k+1;
        if 1 == mod(k,1000)
            featureTable = tempTable;
        else
            featureTable = [featureTable; tempTable];
        end
        if 0 == mod(k,1000)
            save(sprintf('%s/featureTable_%d',fileStruct.folderToSave,x)...
                ,'featureTable');
            featureTable = table;
            x = x+1;
        end
    end
end
save(sprintf('featureTable_%d',x),'featureTable');
end

