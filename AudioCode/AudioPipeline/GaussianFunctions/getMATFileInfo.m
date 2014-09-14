function [ pid, cid, sid ] = getMATFileInfo( fileName )
%GETMATFILEINFO get identification information from mat file
%   the file has to be of the format:
%   anynumberoffolders/pid_cid_sid_anything.mat

fileName = strsplit(fileName,'/');
fileName = fileName{end};
fileName = strsplit(fileName,'_');
pid = str2num(fileName{1});
cid = str2num(fileName{2});
sid = str2num(fileName{3});

end

