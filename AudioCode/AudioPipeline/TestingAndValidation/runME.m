function [ leFrames, cumLEFramesFiles ] = runME( frameSizeInSeconds, frequency,pctlV );
%RUNME A working example of how to run the RMS evaluation
%   Details are provided in rmsThresholdCalculation and in VerifyLowEnergy
%   See also, RMSTHRESHOLDCALCULATION, VERIFYLOWENERGY
[rmsValues, totalRMS, pctl,pname, fname] = rmsThresholdCalculation(frameSizeInSeconds,frequency);
[ leFrames,cumLEFramesFiles ] = VerifyLowEnergy( pname,fname,pctl, frameSizeInSeconds, frequency, pctlV );
end

