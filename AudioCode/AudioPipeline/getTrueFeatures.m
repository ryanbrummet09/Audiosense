function [ trueFeatureMatrix ] = getTrueFeatures( featureMatrix )
%GETTRUEFEATURES returns matrix with only non buzz/beep/LE frame features
%   The audio pipeline outputs a feature matrix. This matrix contains the
%   extracted features from valid (non buzz/beep/low-energy) frames as well
%   as invalid frames. This function removes the invalid frame entries and
%   outputs a matrix containing only the valid frames. The assumption here
%   is that the last three columns of the input matrix represent the
%   indicators for Low-Energy, Buzz, and Beep for the frame.
%
%   Input:
%           featureMatrix       :       The feature matrix extracted from
%                                       using extractFrameFeatures()
%   Output:
%           trueFeatureMatrix   :       The input matrix with the invalid
%                                       frame entries removed
%
%   Usage:
%           trueFeatureMatrix = getTrueFeatures(featureMatrix);
%
%   See also EXTRACTFRAMEFEATURES

trueFeatureMatrix = featureMatrix(featureMatrix(:,end-2)==0 & featureMatrix(:,end-1)==0 & featureMatrix(:,end)==0,:);

end

