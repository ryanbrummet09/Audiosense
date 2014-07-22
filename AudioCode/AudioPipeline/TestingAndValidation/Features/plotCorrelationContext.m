function plotCorrelationContext( x, y, xlabelC, ...
    ylabelC, subplotStatement, removeFiftyX, removeFiftyY,patientID,DSType)
%PLOTCORRELATIONCONTEXT Summary of this function goes here
%   Detailed explanation goes here

%% check nargin
if 7 == nargin
    patientID = 'All';
    DSType = 'Unknown';
elseif 8 == nargin
    DSType = 'Unknown';
end
%% remove NaNs in X and Y
toKeep = true(length(x),1);
for P=1:length(x)
    if isnan(x(P)) | isnan(y(P))
        toKeep(P) = false;
    end
end
x = x(toKeep);
y = y(toKeep);
%% remove 50's
toKeep = true(length(x),1);
for P=1:length(x)
    if (50 == x(P) && removeFiftyX) || (50 == y(P) && removeFiftyY)
        toKeep(P) = false;
    end
end
x = x(toKeep);
y = y(toKeep);
%% if there are less than 10 elements, do not continue
if 3 > length(x)
    disp(sprintf('Too few elements for patient %s attribute %s in type %s',...
        patientID,DSType));
    return;
end
%% calculate correlation
[rho,pval] = corr(x,y,'type','Spearman');

%% get to work on the box plot
if ~isequal(subplotStatement,'')
    eval(subplotStatement);
end

xvals = unique(x);
binInd = nan(length(xvals),2);
boxPlotValues = nan(length(y),length(xvals));
currentPointers = ones(1,length(xvals));
for P=1:length(x)
    binToPutIn = find(xvals==x(P));
    boxPlotValues(currentPointers(1,binToPutIn),binToPutIn) = y(P);
    currentPointers(1,binToPutIn) = currentPointers(1,binToPutIn) + 1;
end
pltLabel = xlabelC;
xlabelC = {};
for P = 1:length(xvals)
    xlabelC{1,P} = num2str(xvals(P));
end
boxplot(boxPlotValues,'labels',xlabelC);
ylabel(ylabelC);
xlabel(pltLabel);
title(sprintf('rho:%f,PID:%s,Type:%s',rho,patientID,DSType));
end

