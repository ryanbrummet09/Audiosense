function [ combinedDS ] = combineRawAudioData(varargin)
%COMBINERAWAUDIODATA Combine the raw audio features with survey data
%   Input:
%           There should be atleast three input arguments, the first one
%           being the table containing the patient identifiers and the
%           path to the feature file, the second one being the table
%           containing the survey data, and the third being the survey
%           feature to map the data on to (this has to be a cell row). The
%           remaining input arguments have to be row vectors of the patient
%           ids and their corresponding condition ids.
%   Output:
%           The output is a table containing the combined values

%% check the inputs and assign them to proper variables
if 2 > nargin
    error('AudioPipeline:DataManipulation:RawAudio',sprintf(...
        'The number of input arguments is %d, I requrire atleast 2',nargin));
elseif 3 == nargin
    % assign the survey as well as the audio ds their proper variables
    audioFeatureDS = varargin{1};
    surveyDataset = varargin{2};
    surveyFeatures = varargin{3};
    pid = nan;
    cid = nan;
elseif 4 == nargin
    audioFeatureDS = varargin{1};
    surveyDataset = varargin{2};
    surveyFeatures = varargin{3};
    pid = varargin{4};
    cid = nan;
else
    audioFeatureDS = varargin{1};
    surveyDataset = varargin{2};
    surveyFeatures = varargin{3};
    pid = varargin{4};
    cid = varargin{5};
end

%% trim down the datasets to deal with only the required users/conditions
if ~isnan(pid)
    % TODO: allow more than one patient ID to be user, an issue to deal
    % with here can be matching multiple conditions with the patient IDs
    toUseSurveyDS = surveyDataset(surveyDataset.patient==pid,:);
    toUseAudioFeatureDS = audioFeatureDS(audioFeatureDS.patient==pid,:);
    if ~isnan(cid)
        toUseSurveyDS = toUseSurveyDS(toUseSurveyDS.condition==cid,:);
        toUseAudioFeatureDS = toUseAudioFeatureDS(...
            toUseAudioFeatureDS.condition==cid,:);
    end
else
    toUseSurveyDS = surveyDataset;
    toUseAudioFeatureDS = audioFeatureDS;
end
%% start mapping
% load the audio features
featureTitle = {'patient','condition','session','ZCR','RMS','Entropy',...
    'SRF'};
for P=0:12
    featureTitle{end+1} = sprintf('mfcc%d',P);
end
featureTitle{end+1} = 'LowEnergy';
featureTitle{end+1} = 'Buzz';
featureTitle{end+1} = 'Beep';
for P=1:length(surveyFeatures)
    featureTitle{end+1} = surveyFeatures{P};
end
%  initialize the combined dataset with the variable names
combinedDS = table;
combinedDS.Properties.VariableNames = featureTitle;
pids = toUseSurveyDS.patient;
cids = toUseSurveyDS.condition;
sids = toUseSurveyDS.session;
% get the actual feature values
for P=1:length(pids)
    fpath = toUseAudioFeatureDS.path(...
        toUseAudioFeatureDS.patient==pids(P) & ...
        toUseAudioFeatureDS.condition==cids(P) & ...
        toUseAudioFeatureDS.session==sids(P));
    if isempty(fpath)
%         if no audio file exists for the corresponding survey
        continue;
    end
    tempFF = load(fpath);
    tempFF = tempFF.var;
    tempFF = num2cell(tempFF);
    [r c] = size(tempFF);
    surveyVals = {};
    for Q=1:length(surveyFeatures)
        toExecute = sprintf('toUseSurveyDS.%s(toUseSurveyDS.patient==pids(P) & toUseSurveyDS.condition==cids(P) & toUseSurveyDS.session==sids(P));',...
            surveyFeatures{Q});
        surveyVals{1,Q} = eval(toExecute);
    end
    surveyVals = repmat(surveyVals,r,1);
    tempFF(:,end+1:end+Q) = surveyVals;
    tempTable = cell2table(tempFF);
    tempTable.Properties.VariableNames = featureTitle;
    combinedDS = [combinedDS; tempTable];
end
end
