function [ op_datenums ] = getDatenums( datevals )
%GETDATENUMS Summary of this function goes here
%   Detailed explanation goes here
[r,~] = size(datevals);
op_datenums = zeros(r,1);

for P=1:r
    temp = datevals{P};
    temp = strsplit(temp,' ');
    temp = temp{1};
    op_datenums(P,1) = datenum(temp,'yyyy-mm-dd');
end
end

