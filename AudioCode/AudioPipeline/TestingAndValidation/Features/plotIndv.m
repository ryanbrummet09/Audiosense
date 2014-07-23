function plotIndv( varargin )
%PLOTINDV Summary of this function goes here
%   Detailed explanation goes here
x = varargin{1};
y = varargin{2};

toKeep = true(size(x));
for P=1:length(x)
    if isnan(x(P)) | isnan(y(P))
        toKeep(P) = false;
    end
end
x = x(toKeep);
y = y(toKeep);

if 4 == length(varargin)
    % remove x values
    toRemoveX = varargin{4};
    toRemoveY = varargin{3};
    toKeep = true(size(x));
    for P=1:length(x)
        if toRemoveX == x(P) | toRemoveY == y(P)
            toKeep(P) = false;
        end
    end
    x = x(toKeep);
    y = y(toKeep);
elseif 3 == length(varargin)
    toRemoveY = varargin{3};
    toKeep = true(size(x));
    for P=1:length(x)
        if toRemoveY == y(P)
            toKeep(P) = false;
        end
    end
    x = x(toKeep);
    y = y(toKeep);
end
disp(sprintf('No. of data points = %d',length(x)));
plot(x,y,'bo');
h = lsline;
set(h,'Color',[1 0 0]);
b = robustfit(x,y);
b
ynew = nan(size(y));
ynew = b(1) + b(2)*y;
hold on;
xnew = nan(size(x));
[temps,xind] = sort(x);
xnew = x(xind);
yn = ynew(xind);
line([xnew(1) xnew(end)], [yn(1) yn(end)],'Color','g');
end

