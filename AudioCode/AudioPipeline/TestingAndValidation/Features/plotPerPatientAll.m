function [varargout] = plotPerPatientAll( varargin )
%PLOTPERPATIENTALL Summary of this function goes here
%   Detailed explanation goes here
tempOutTable = table;
attList = {'RMS','ZCR','SRF','Entropy'};
for P=0:1:12
    attList{end+1} = sprintf('mfcc%d',P);
end
if nargin < 3
    error('AudioPipeline:Testing:Feature:plotPerPatientAll',...
        'Too few arguments, I need atleast three.');
end

%% check the arguments
boxOutcomes = varargin{1};

if ~islogical(boxOutcomes)
    boxOutcomes = false;
end
if ~iscell(varargin{2}) || (length(varargin{2}) ~= length(varargin)-2)
    for P=1:length(varargin)-2
        DSTypes{P} = 'Unknown';
    end
else
    DSTypes = varargin{2};
end
for P = 3:1:length(varargin)
    if ~istable(varargin{P})
        error('AudioPipeline:Testing:Feature:plotPerPatientAll',...
            sprintf('Variable # %d is not a table, expected a table',P));
    end
end

%% for each of the DSs separate the patients
for P=3:1:length(varargin)
    DS = varargin{P};
    DSType = DSTypes{P-2};
    plist = unique(DS.patient);
    for Q=1:length(plist)
        temp = DS(DS.patient==plist(Q),:);
        if height(temp) < 10
            warning('AudioPipeline:Testing:Feature:plotPerPatientAll',...
                sprintf('Very few elements (P:%d,T:%s), only %d found',...
                plist(Q),DSType,height(temp)));
            continue;
        end
        temp = plotAllFunction(temp,attList,boxOutcomes,DSType,num2str(plist(Q)));
        tempOutTable = [tempOutTable; temp];
    end
end
varargout{1} = tempOutTable;
end


