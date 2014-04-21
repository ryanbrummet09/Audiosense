function [ featureVector ] = updateFeatureVector( fv, giveUpdate )
%UPDATEFEATUREVECTOR adds the current features to the featureVector
%   This function appends the feature vector to the global feature vector
%   and returns the value when asked through giveUpdate

featureVector = [];
persistent initialized;
persistent featureVectorInternal;

if isempty(initialized)
    initialized = true;
    featureVectorInternal = [];
    featureVectorInternal(end+1,:) = fv;
else
    if giveUpdate
        featureVector = featureVectorInternal;
    else
       featureVectorInternal(end+1,:) = fv;
    end
end

end

