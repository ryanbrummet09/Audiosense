function [ aggregatedFeatures ] = aggregateAudioFeatures( matFilePath, ...
                                    statisticFunctionHandle)
%AGGREGATEAUDIOFEATURES calculates the spec. statistics for each audio file
%   Input:
%           matFilePath             :       string containing the full file
%                                           path of the audio file
%           statisticFunctionHandle :       the function handle to the
%                                           statistic that needs to be
%                                           calculated. Currently we only
%                                           support @median(default),
%                                           @mean and @kurtosis.
%                                       
%   Output:
%           aggregatedFeatures      :       the features of the given file
%                                           aggregated using the statistic
%                                           passed as the argument

if ~(isequal(statisticFunctionHandle, @median) | ...
        isequal(statisticFunctionHandle,@mean) |...
        isequal(statisticFunctionHandle,@kurtosis))
    statisticFunctionHandle = @median;
end
                        
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
    feature = feature(~isinf(feature(:)));
    aggregatedFeatures(1,P) = feval(statisticFunctionHandle,feature);
end

end

