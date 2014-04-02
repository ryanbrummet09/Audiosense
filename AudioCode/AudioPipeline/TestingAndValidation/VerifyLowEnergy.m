function [ leFrames,cumLEFramesFiles ] = VerifyLowEnergy( pname,fname,pctl, frameSizeInSeconds, frequency, pctlV )
%VERIFYLOWENERGY combines the low energy frames and saves them to a file
%   Usage: [lowEnergyFrames, cumulativeLowEnergyFrames] = VerifyLowEnergy(
%   path, filenameCells, percentileArray, frameSizeInSeconds, Frequency,
%   percentileValueToUse);
%
%   Input:
%           path, filenameCells,        :       Obtained from
%           percentileArray                     rmsThresholdCalculation
%           frameSizeInSeconds          :       Frame size in seconds
%           Frequency                   :       Frequency of sampling
%           percentileValueToUse        :       percentileArray index to use           
%
%   Output:
%           leFrames                    :       A cell array of matrices,
%                                               each matrix represents the
%                                               low energy frames (rows of
%                                               the matrix)
%           cumulativeLowEnergyFrames   :       cell array, each cell
%                                               contains a continuous
%                                               low-energy frame stream.
%                                               This is essentially, the
%                                               leFrames for a particular
%                                               file concatenated
%
%
%   See also, RMSTHRESHOLDCALCULATION
addpath ../;
addpath ../voicebox;
leFrames = {};
dirN = strcat('LE_',num2str(pctlV));
mkdir(dirN);
cumLEFramesFiles = {};
for P=1:length(fname)
    perFileFrames = [];
    cumLEFrames = [];
    data = getSoundData(strcat(pname,fname{P}));
    frames = enframe(data, frameSizeInSeconds*frequency, frameSizeInSeconds*frequency,'r');
    for Q = 1:length(frames)
        if rms(frames(Q,:)) <= pctl(pctlV)
            perFileFrames(end+1,:) = frames(Q,:);
            cumLEFrames = horzcat(cumLEFrames,frames(Q,:));
        end
    end
    s = strcat(dirN,'/LE_',num2str(pctlV),'_',fname{P});
    f = fopen(s,'w');
    fwrite(f,cumLEFrames,'short',0,'l');
    fclose(f);
    s = sprintf('Written %s',s);
    disp(s);
    cumLEFramesFiles{end+1} = cumLEFrames;
    leFrames{end+1} = perFileFrames;
end
end

