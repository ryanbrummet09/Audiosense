function [ aggregatedFeatures ] = aggregateAudioFeatures( matFilePath, ...
                                    statisticFunctionHandle)
%AGGREGATEAUDIOFEATURES calculates the spec. statistics for each audio file
%   Detailed explanation goes here

temp = load(matFilePath);
temp = temp.var;
[r,c] = size(temp);
aggregatedFeatures = nan(1,c-3);
aggregatedFeatures(1,1) = temp(1,1);
aggregatedFeatures(1,2) = temp(1,2);
aggregatedFeatures(1,3) = temp(1,3);
for P=4:c-3
    feature = temp(:,P);
    % make sure that the NaNs are removed before computing the statistic
    feature = feature(~isnan(feature(:)));
    aggregatedFeatures(1,P) = feval(statisticFunctionHandle,feature);
end

end

