function [ appendedFeatures ] = getAndAppend( listOfFiles )
%GETANDAPPEND Summary of this function goes here
%   Detailed explanation goes here


appendedFeatures = [];
for P=1:length(listOfFiles)
    t = load(listOfFiles{P});
    t = t.var;
    appendedFeatures = [appendedFeatures; t];
end

end

