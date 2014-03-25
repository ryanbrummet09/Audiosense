function [ pid,cid,sid ] = getInfo( audioFilename )
%GETINFO Summary of this function goes here
%   Detailed explanation goes here

contents = upper(strsplit(audioFilename,'.'));
t = strsplit(contents{1},'-');
t = strsplit(t{2},'EMA');
pid = str2num(t{2});
cid = str2num(contents{2});
sid = str2num(contents{3});
end

