function fitGaussianParallel( trainingSet, startAt, ...
                            endAt, toSaveTag, toSaveAt )
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
%           toSaveTag           :           an optional parameter to put in
%                                           the saved variable name
%           toSaveAt            :           optional parameter, indicates
%                                           location at which to save the
%                                           GMM Object
%   Values are stored in the dataVariables folder
customSaveFlag = true;
if 3 == nargin
    toSaveTag = '';
    toSaveAt = '';
    customSaveFlag = false;
elseif 4 == nargin
    toSaveAt = '';
    customSaveFlag = false;
end
if endAt < startAt
    error('GaussianFunctions:parallel','endsAt < startsAt');
end
trainingSet = normValues(trainingSet);
parObject = parpool;
if 7 ~= exist('dataVariables','dir')
    mkdir('dataVariables');
end
parfor P=startAt:endAt
    disp(sprintf('Fitting %d gaussians',pow2(P)));
    GMMObject = fitGaussianDistribution(trainingSet(:,5:end),pow2(P));
    if ~customSaveFlag
        parSaveVariable(sprintf('dataVariables/GMMObj_%s%d',toSaveTag,...
            pow2(P)),GMMObject);
    else
        parSaveVariable(sprintf('%s/GMMObj_%s%d',toSaveAt,toSaveTag,...
                        pow2(P)),GMMObject);
    end
end
delete(parObject);

end

