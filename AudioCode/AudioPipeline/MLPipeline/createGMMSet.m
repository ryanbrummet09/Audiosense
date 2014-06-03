function [ GMMSet ] = createGMMSet( trainingSet )
%CREATEGMMSET creates the GMM set from the training set
%   This takes as input the training set and create a set of features that
%   can be used to create the GMM object.

[r,c] = size(trainingSet);
if 100000 <= r
    GMMSet = datasample(trainingSet,100000,'replace',false);
else
    GMMSet = datasample(trainingSet,floor(r/2),'replace',false);
end

end

