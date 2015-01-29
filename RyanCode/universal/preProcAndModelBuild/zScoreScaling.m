% Ryan Brummet
% University of Iowa
%
% scales the input matrix, by column, using the zscore.  This function will
% not remove predictors where min == max.  If you'd like this behaviour,
% you must either preprocess data to achieve it or use another scaling
% function.
%
%   Input:
%           toScaleMatrix           :           Matrix to be scaled between
%                                               0 and 1.  Must not include
%                                               categorical columns.
%   Output:
%           scaledMatrix            :           Scaled version of
%                                               toScaleMatrix
%           mn                      :           dummy variable.  Exists
%                                               to simplfy code to handle
%                                               other scaling functions.
%                                               Here it returns the name of
%                                               the scaling function used
%           mx                      :           dummy variable.  Exists
%                                               to simplfy code to handle
%                                               other scaling functions.  
%                                               Here it returns the name of
%                                               the scaling function used
%           badColumns              :           A vector containing the
%                                               column numbers where
%                                               minimum and maximum values
%                                               are the same.  Notice that
%                                               no bad columns are
%                                               generated with this
%                                               particular scaling function
%                                               and so badColumns will
%                                               always be NaN.

function [ scaledMatrix, mn, mx, badColumns ] = zScoreScaling( toScaleMatrix, ~, ~ )
    badColumns = [];
    [r,c] = size(toScaleMatrix);
    scaledMatrix = zeros(r,c);
    for k = 1 : c
        scaledMatrix(:,k) = zscore(toScaleMatrix(:,k));
    end
    mn = 'zscore';
    mx = 'zscore';
end

