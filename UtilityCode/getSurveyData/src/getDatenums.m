function [ op_datenums ] = getDatenums( datevals, audioD )
%GETDATENUMS Summary of this function goes here
%   Detailed explanation goes here
if 1 == nargin
    audioD = false;
end
[r,~] = size(datevals);
op_datenums = zeros(r,1);

for P=1:r
    temp = datevals{P};
    if audioD
        temp = strsplit(temp,'/');
        temp = temp{end};
        temp = strsplit(temp,'.');
        temp = temp{4};
        op_datenums(P,1) = datenum(temp,'yyyy-mm-dd HH-MM-SS');
    else
        temp = strsplit(temp,' ');
        temp = temp{1};
        op_datenums(P,1) = datenum(temp,'yyyy-mm-dd');
    end
end
end

