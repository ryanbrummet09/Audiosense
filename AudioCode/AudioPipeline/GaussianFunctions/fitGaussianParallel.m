function fitGaussianParallel( trainingSet, startAt, ...
                            endAt )
%FITGAUSSIANPARALLEL fits gaussians in parallel
%   Input:
%           trainingSet         :           the set on which the gaussians
%                                           need to be fit, the first three
%                                           columns contain identifier
%                                           information and shall be
%                                           ignored
%           startAt             :           power of 2 to start the number
%                                           of gaussians at
%           endAt               :           power of 2 to end the number of
%                                           gaussians at, this has to be,
%                                           of course, less than startAt
%   Values are stored in the dataVariables folder
if endAt < startAt
    error('GaussianFunctions:parallel','endsAt < startsAt');
end
trainingSet = normValues(trainingSet);
parObject = parpool(3);
if 7 ~= exist('dataVariables','dir')
    mkdir('dataVariables');
end
parfor P=startAt:endAt
    disp(sprintf('Fitting %d gaussians',pow2(P)));
    GMMObject = fitGaussianDistribution(trainingSet(:,4:end),pow2(P));
    parSaveVariable(sprintf('dataVariables/GMMObj_%d',pow2(P)),GMMObject);
end
delete(parObject);

end

