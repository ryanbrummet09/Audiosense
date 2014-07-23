function [varargout] = plotCorrelation( x, y, xlabelC, ylabelC, subplotStatement, ...
                          removeFiftyX, removeFiftyY, boxThePlot, ...
                          patientID, DSType)
%PLOTCORRELATION Summary of this function goes here
%   Detailed explanation goes here

%% check inputs
if 7 == nargin
    boxThePlot = false;
    patientID = 'All';
    DSType = 'Unknown';
elseif 8 == nargin
    patientID = 'All';
    DSType = 'Unknown';
elseif 9 == nargin
    DSType = 'Unknown';
end
pltLabel = xlabelC;

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

if boxThePlot
        pctl = 30:30:100;
        xpctl = prctile(x,pctl);
        bins = [];
        % create the bins
        for P=1:length(xpctl)
            if 1 == P
                bins(1,1) = 0;  bins(1,2) = xpctl(1);
                continue;
            end
            bins(P,1) = bins(P-1,2);    bins(P,2) = xpctl(P);
        end
        [r, c] = size(bins);
        boxPlotInput = cell(1,r);
        for P=1:r
            boxPlotInput{1,P} = [];
        end
        for P=1:length(x)
        for Q=1:r
            if 1 == Q
                if (bins(Q,1) <= x(P)) && (x(P) <= bins(Q,2))
                    temp = boxPlotInput{1,Q};
                    temp(end+1,1) = y(P);
                    boxPlotInput{1,Q} = temp;
                    break;
                end
            end
            if (bins(Q,1) < x(P)) && (x(P) <= bins(Q,2))
                temp = boxPlotInput{1,Q};
                temp(end+1,1) = y(P);
                boxPlotInput{1,Q} = temp;
                break;
            end
        end
        end
        n = -1;
        for P=1:r
            l = length(boxPlotInput{1,P});
            if l >= n
                n = l;
            end
        end
        finalBPInput = nan(n,r);
        xlabelC = {};
        for P=1:r
            m = length(boxPlotInput{1,P});
            finalBPInput(1:m,P) = boxPlotInput{1,P};
        end
        for P=1:r
            xlabelC{1,P} = sprintf('%.2f',bins(P,2));
        end
        boxplot(finalBPInput,'label',xlabelC);
        ylabel(ylabelC);
        xlabel(pltLabel);
        title(sprintf('rho:%f,PID:%s,Type:%s',rho,patientID,...
            DSType));
        varargout{1} = table;
 else
        plot(x,y,'bo');
        h = lsline;
        set(h,'Color',[1 0 0]);
        b = robustfit(x,y);
        ynew = nan(size(y));
        ynew = b(1) + b(2)*y;
        hold on;
        [temps, xind] = sort(x);
        xn = x(xind);
        yn = ynew(xind);
        line([xn(1) xn(2)], [yn(1) yn(2)],'Color','g');
        xlabel(xlabelC);
        ylabel(ylabelC);
        title(sprintf('rho:%f,PID:%s,Type:%s',rho,patientID,...
            DSType));
        tempArgOut = {'patient','DSType','xType','yType','rho','x0','x1';...
            patientID, DSType,pltLabel,ylabelC, rho, b(1), b(2)};
        varargout{1} = cell2table(tempArgOut);
end
end

