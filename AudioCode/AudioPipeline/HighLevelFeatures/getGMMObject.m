function [ GMMObj ] = getGMMObject( trainingSet, startIndex, endIndex, numberOfModels )
%GETGMMOBJECT Creates a GMM with the specified number of models
%   Input:
%           trainingSet         :       The set of values over which the
%                                       GMM has to be trained
%           startIndex,endIndex :       The starting and ending index of 
%                                       the features in the training set
%           numberOfModels      :       Number of Gaussian models to fit
%                                       the data
%   Output:
%           GMMObj              :       The GMM distribution object
GMMObj = gmdistribution.fit(trainingSet(:,startIndex:endIndex),numberOfModels);

end

