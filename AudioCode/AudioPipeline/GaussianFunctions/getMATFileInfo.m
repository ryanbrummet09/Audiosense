function [ pid, cid, sid, otherInfo ] = getMATFileInfo( fileName,multLabel )
%GETMATFILEINFO get identification information from mat file
%   the file has to be of the format:
%   anynumberoffolders/pid_cid_sid_anything.mat
%   the multLabel flag indicates that we also want the label info

if 1 == nargin
    multLabel = false;
end
fileName = strsplit(fileName,'/');
fileName = fileName{end};
fileName = strsplit(fileName,'_');
pid = str2num(fileName{1});
cid = str2num(fileName{2});
sid = str2num(fileName{3});
otherInfo = {};
if multLabel
    otherInfo = fileName{4};
    if strcmpi(fileName{4},'media')
        otherInfo = strcat(fileName{4},'_',fileName{5});
    end
    % the next line is just some mop up work because of a spelling error
    if strcmpi(otherInfo,'speecj')
        otherInfo = 'speech';
    end
    otherInfo = strsplit(otherInfo,'.');
    otherInfo = otherInfo{1};
end

end

