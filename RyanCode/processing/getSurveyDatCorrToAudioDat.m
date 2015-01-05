% Ryan Brummet
% University of Iowa

% Extracts survey info for each audioFeature file.  Code only works for
% patients numbered 1-99.  Higher or lower numbers for patient id's will
% create problems for this script

close all;
clear;
clc;

%% Define Variable Params.  Nothing should be changed outside this section

% give path to all files in AudioStuff directory
addpath(genpath('/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff'));

% paths to raw survey data and audio features
surveyDataLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/audiologyPhoneData';
audioFeatureLocation = '/Users/ryanbrummet/Documents/MATLAB/Audiology/AudioStuff/features/fileFeatures';

%% Find the id's of all surveys corresponding to audioFeature files

% get identifying info of audio feature files
audioFeatureFileNames = dir(audioFeatureLocation);
patientDirFileNames = dir(surveyDataLocation);
audioFeatureFileNames = extractfield(audioFeatureFileNames,'name')';
patientDirFileNames = extractfield(patientDirFileNames,'name')';
audioFeatureFileNames(1:3) = [];
patientDirFileNames(1:3) = [];
for k = 1 : size(audioFeatureFileNames,1)
    audioFeatureFileInfo(k,:) = strsplit(audioFeatureFileNames{k},{'_','.','-'});
end
audioFeatureFileInfo = array2table(audioFeatureFileInfo(:,2:7),'VariableNames',{'patient','condition','session','year','month','date'});

index = 1;
for k = 1 : size(audioFeatureFileInfo,1)
    practiceTest = false;
    if str2double(audioFeatureFileInfo{k,1}) < 10
        if str2double(audioFeatureFileInfo{k,2}) < 10
            currentFileName = strcat(surveyDataLocation,'/EMA0',audioFeatureFileInfo.patient{k},'/Condition 0',audioFeatureFileInfo.condition{k});
        else
            if str2double(audioFeatureFileInfo{k,2}) > 90
                practiceTest = true;
            else
                currentFileName = strcat(surveyDataLocation,'/EMA0',audioFeatureFileInfo.patient{k},'/Condition',{' '},audioFeatureFileInfo.condition{k});
            end
        end
    else
        if str2double(audioFeatureFileInfo{k,2}) < 10
            currentFileName = strcat(surveyDataLocation,'/EMA',audioFeatureFileInfo.patient{k},'/Condition 0',audioFeatureFileInfo.condition{k});
        else
            if str2double(audioFeatureFileInfo{k,2}) > 90
                practiceTest = true;
            else
                currentFileName = strcat(surveyDataLocation,'/EMA',audioFeatureFileInfo.patient{k},'/Condition',{' '},audioFeatureFileInfo.condition{k});
            end
        end
    end
    
    if practiceTest 
        if str2double(audioFeatureFileInfo.patient{k}) < 10
            currentFileName = strcat(surveyDataLocation,'/EMA0',audioFeatureFileInfo.patient{k});
        else
            currentFileName = strcat(surveyDataLocation,'/EMA',audioFeatureFileInfo.patient{k});
        end
        if iscell(currentFileName)
            currentFileName = currentFileName{1}; 
        end
        currentDir = struct2table(dir(currentFileName));
        currentDir(1:2,:) = [];
        for j = 1 : size(currentDir,1)
            tempKeep = strsplit(currentDir.name{j},{' '});
            if strcmp(tempKeep{1},'.DS_Store')
                continue; 
            end
            if str2double(tempKeep{2}(1)) == 9
                temp = strcat(currentFileName,'/Condition',{' 9'},tempKeep{2}(2));
                if iscell(temp)
                    temp = temp{1}; 
                end
                tempFileSet = dir(temp);
                tempFileSet = extractfield(tempFileSet,'name')';
                tempFileSet(1:2) = [];
                for i = 1 : size(tempFileSet,1)
                    temp = tempFileSet{i};
                    if strcmp(temp(1),'p')
                        tempFileInfo = strsplit(tempFileSet{i},{'.','-',' '});
                        if size(tempFileInfo,2) ~= 11
                            continue;
                        end
                        if str2double(tempFileInfo(4)) == str2double(audioFeatureFileInfo.session(k)) ...
                                && str2double(tempFileInfo(5)) == str2double(audioFeatureFileInfo.year(k)) ...
                                && str2double(tempFileInfo(6)) == str2double(audioFeatureFileInfo.month(k)) ...
                                && str2double(tempFileInfo(7)) == str2double(audioFeatureFileInfo.date(k))
                            
                            currentFileNameTemp = strcat(currentFileName,'/Condition',{' 9'},tempKeep{2}(2));
                            if iscell(currentFileNameTemp)
                                currentFileNameTemp = currentFileNameTemp{1}; 
                            end
                            if strcmp(tempFileInfo{end},'survey')
                                audioSurveyPairs(index,1) = cellstr(strcat(currentFileNameTemp,'/',tempFileSet{i}));
                                audioSurveyPairs(index,2) = cellstr(strcat(audioFeatureLocation,'/',audioFeatureFileNames{k}));
                                index = index + 1;
                                practiceTest = false;
                                break;
                            else
                                for g = i + 1 : size(tempFileSet,1)
                                    temp = tempFileSet{g};
                                    if strcmp(temp(1),'p')
                                        tempFileInfo = strsplit(tempFileSet{g},{'.','-',' '});
                                        if size(tempFileInfo,2) ~= 11
                                            continue;
                                        end
                                        if str2double(tempFileInfo(4)) == str2double(audioFeatureFileInfo.session(k)) ...
                                                && str2double(tempFileInfo(5)) == str2double(audioFeatureFileInfo.year(k)) ...
                                                && str2double(tempFileInfo(6)) == str2double(audioFeatureFileInfo.month(k)) ...
                                                && str2double(tempFileInfo(7)) == str2double(audioFeatureFileInfo.date(k)) ...
                                                && strcmp(tempFileInfo{end},'survey')
                                            
                                            audioSurveyPairs(index,1) = cellstr(strcat(currentFileNameTemp,'/',tempFileSet{g}));
                                            audioSurveyPairs(index,2) = cellstr(strcat(audioFeatureLocation,'/',audioFeatureFileNames{k}));
                                            index = index + 1;
                                            practiceTest = false;
                                            break;
                                        end
                                    end
                                end
                                break;
                            end
                        end
                    end
                end
                if practiceTest == false;
                    break;
                end
            end
        end
    else
        if iscell(currentFileName)
            currentFileName = currentFileName{1}; 
        end
        currentFileSet = dir(currentFileName);
        currentFileSet = extractfield(currentFileSet,'name')';
        currentFileSet(1:2) = [];
        for j = 1 : size(currentFileSet,1)
            temp = currentFileSet{j};
            if strcmp(temp(1),'p')
                currentFileInfo = strsplit(currentFileSet{j},'.');
                if size(currentFileInfo,2) == 2
                    continue;
                end
                if str2double(currentFileInfo(3)) == str2double(audioFeatureFileInfo.session(k)) && strcmp(currentFileInfo{5},'survey')
                    audioSurveyPairs(index,1) = cellstr(strcat(currentFileName,'/',currentFileSet{j}));
                    audioSurveyPairs(index,2) = cellstr(strcat(audioFeatureLocation,'/',audioFeatureFileNames{k}));
                    index = index + 1;
                    break;
                end
            end
        end
    end
    disp(size(audioFeatureFileInfo,1) - k);
end
audioSurveyPairs = array2table(audioSurveyPairs,'VariableNames',{'SurveyLocation','AudioFeatureLocation'});
save('audioSurveyPairs','audioSurveyPairs');


