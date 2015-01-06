function [ ipDataset ] = removeMultipleAudio( ipDataset )
%REMOVEMULTIPLEAUDIO identify audio files associated with multiple surveys
%   Input:
%           ipDataset : the dataset extracted using the python script
%   Output:
%           ipDataset : the input dataset with an additional field,
%                       oneAudioWithMoreSurvey. This field has 1's wherever
%                       the audio file is associated with more than one
%                       survey file

af = ipDataset.audioPath;
uL = unique(af);
n = length(uL);
toRemove = zeros(height(ipDataset),1);
ipDataset.oneAudioWithMoreSurvey = toRemove;
for P=1:n
    temp = ipDataset(strcmp(ipDataset.audioPath,uL{P}),:);
    if 1 ~= height(temp)
        ipDataset.oneAudioWithMoreSurvey(strcmp(ipDataset.audioPath,uL{P})) = 1;
    end
end
end

