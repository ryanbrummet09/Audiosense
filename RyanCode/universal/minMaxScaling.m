% Syed Shabih Hasan
% University of Iowa
%
% minMaxScaling Scale data intelligently between a given interval 
%   Input:
%           toScaleMatrix           :           Matrix to be scaled between
%                                               0 and 1.  Must not include
%                                               categorical columns.
%           mn                      :           Minimum value generated
%                                               using a previous run of
%                                               minMaxScaling
%           mx                      :           Maximum value generated
%                                               using a previous run of
%                                               minMaxScaling
%           lowV                    :           The minimum value to be
%                                               scaled to, default is 0
%           highV                   :           The maximum value to be
%                                               scaled to, default is 1
% 
%   Output:
%           scaledMatrix            :           Scaled version of
%                                               toScaleMatrix
%           mn                      :           Minimum values for columns
%                                               of toScaleMatrix
%           mx                      :           Maximum values for columsn
%                                               of toScaleMatrix
%           badColumns              :           A vector containing the
%                                               column numbers where
%                                               minimum and maximum values
%                                               are the same
% 
%  Usage:
%       Scale values between -1 and 1
%           [scaledMatrix, minValue, maxValue] = ...
%                  minMaxScaling(trainingSetAudioFeatures,-1,1);
%       Scale values between -1 and 1 using custom minimum and maximums
%           [scaledMatrix, ~, ~] = ...
%                  minMaxScaling(testingSetAudioFeatures, -1, 1, ...
%    

function [ scaledMatrix, mn, mx, badColumns ] = minMaxScaling( ...
                                            toScaleMatrix, lowV, highV, ...
                                            mn, mx)
    if 1 == nargin
        mn = nanmin(toScaleMatrix);
        mx = nanmax(toScaleMatrix);
        lowV = 0;
        highV = 1;
    elseif 3 == nargin
        mn = nanmin(toScaleMatrix);
        mx = nanmax(toScaleMatrix);
    end
    badColumns = [];
    [r,c] = size(toScaleMatrix);

    scaledMatrix = zeros(r,c);

    for P=1:c
        if mn(P) == mx(P)
            badColumns(end+1) = P;
            continue;
        else
            scaledMatrix(:,P) = ...
                (((toScaleMatrix(:,P)-mn(P))*(highV-lowV))/(mx(P)-mn(P)))+lowV;
        end
    end
    
    scaledMatrix(:,badColumns) = [];

end