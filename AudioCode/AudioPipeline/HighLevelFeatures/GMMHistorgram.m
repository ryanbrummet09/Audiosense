function [ GMMHist ] = GMMHistorgram( inputSet, GMMObj, startIndex, endIndex)
%GMMHISTORGRAM Creates a GMM histogram of the input set of features
%   
%   This creates a histogram of the input set of features.
%   Input:
%           inputSet        :       Input set of values, each row is
%                                   a separate frame
%           GMMObj          :       GMM object obtained as an output from
%                                   gmmdistribution.fit
%           startIndex
%           endIndex        :       The starting and ending indices
%                                   (in the inputSet) of the
%                                   feature we have built the GMM of
% 
%   Output:
%           GMMHist         :       The histogram, each row represents one
%                                   whole file. The output is of the
%                                   following form
%   [patientID, conditionID, session ID, histogram for each model]

[r c] = size(GMMObj.mu);
numberOfModels = r;
modelsMu = GMMObj.mu;
modelsSigma = GMMObj.Sigma;
GMMHist = [];
[r c] = size(inputSet);
temp = zeros(1,numberOfModels);

for P = 1:r
    if isempty(GMMHist) | isempty(GMMHist(GMMHist(:,1)==inputSet(P,1) & ...
            GMMHist(:,2)==inputSet(P,2) & ...
            GMMHist(:,3)==inputSet(P,3), :))
       t = horzcat([inputSet(P,1),inputSet(P,2),inputSet(P,3)],temp);
       GMMHist(end+1,:) = t;
    end
end

for P = 1:r
    mPDF = [];
    for Q=1:numberOfModels
    mPDF(end+1) = mvnpdf(inputSet(P,startIndex:endIndex),modelsMu(Q,:),modelsSigma(:,:,Q));
    end
    toUpdate = find(mPDF == max(mPDF));
    if length(toUpdate)>1
        toUpdate = datasample(toUpdate,1);
    end
    GMMHist(GMMHist(:,1)==inputSet(P,1) & ...
        GMMHist(:,2)==inputSet(P,2) & ...
        GMMHist(:,3)==inputSet(P,3),toUpdate) = GMMHist(GMMHist(:,1)==inputSet(P,1) & ...
                                                GMMHist(:,2)==inputSet(P,2) & ...
                                                GMMHist(:,3)==inputSet(P,3),toUpdate) +1;
    
end

end

