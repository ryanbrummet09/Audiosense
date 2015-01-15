function [ combinedTable ] = combineOutputs( fileList )
%COMBINEOUTPUTS Combine the outputs from openSMILE
%   Input:
%           fileList        :   Matlab cell vector containing full path of
%                               the extracted outputs
%   Output:
%           combinedTable   :   Table containing features
% 
combinedTable = table;

for P=1:length(fileList)
    try
        tempTable = importOpenSmileOutput(fileList{P});
        combinedTable = [combinedTable; tempTable];
    catch err
        disp(sprintf('There was an error for (%d) %s, Skipping',...
            P,fileList{P}));
        continue;
    end
end

end

