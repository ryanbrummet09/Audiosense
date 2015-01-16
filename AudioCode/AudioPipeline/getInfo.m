function [ pid,cid,sid,fdate ] = getInfo( audioFilename, extractDatenum )
%GETINFO Summary of this function goes here
%           audioFilename       :           name of audio file
%           extractDatenum      :           Flag indicating if serial
%                                           datenum should be extracted
%                                           instead of actual date and time
%                                           values
%   Output:
%           pid                 :           patient id
%           cid                 :           condition id
%           sid                 :           session id
%           fdate               :           date and time or serial date,
%                                           depending on extractDatenum
%                                           flag

if 1 == nargin
    extractDatenum = false;
end
fname = upper(audioFilename);
contents = strsplit(fname,'/');
contents = contents{end};
contents = upper(strsplit(contents,'.'));
t = strsplit(contents{1},'-');
t = strsplit(t{end},'EMA');
pid = str2num(t{end});
cid = str2num(contents{2});
sid = str2num(contents{3});
fdate = contents{4};
if extractDatenum
    fdate = datenum(fdate, 'yyyy-mm-dd HH-MM-SS');
end
end

