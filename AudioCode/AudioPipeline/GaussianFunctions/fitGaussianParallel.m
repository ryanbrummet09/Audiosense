function fitGaussianParallel( trainingSet, startAt, ...
                            endAt, toSaveAt, toSaveTag )
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
%   Values are stored in the dataVariables folder
if 3 == nargin
    toSaveTag = '';
    toSaveAt = '';
elseif 4 == nargin
    toSaveTag = '';
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
    if 3 >= nargin | (4 == nargin & strcmp('',toSaveAt))
        parSaveVariable(sprintf('dataVariables/GMMObj_%s%d',toSaveTag,...
            pow2(P)),GMMObject);
    else
        parSaveVariable(sprintf('%s/GMMObj_%s%d',toSaveTag,pow2(P),...
            GMMObject));
    end
end
delete(parObject);

end

