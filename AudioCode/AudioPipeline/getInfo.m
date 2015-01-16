function [ pid,cid,sid,fdate ] = getInfo( audioFilename )
%GETINFO Summary of this function goes here
%   Detailed explanation goes here
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
fdate = datenum(fdate, 'yyyy-mm-dd HH-MM-SS');
end

