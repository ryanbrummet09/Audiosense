function [ GMMObject ] = fitGaussianDistribution( toFit, k )
%FITGAUSSIANDISTRIBUTION fits k gaussians on the toFit Dataset
%   Input:
%           toFit           :           dataset to fit the gaussians on,
%                                       this has to be a matrix
%           k               :           number of gaussians to fit
%   Output:
%           GMMObject       :           GMM object generated after fitting
%                                       the data

GMMObject = fitgmdist(toFit,k,'Regularize',1e-5);
end

