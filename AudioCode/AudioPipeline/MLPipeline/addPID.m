function [ fileList ] = addPID( fileList )
%ADDPID adds the patient id to the input file
%   This extracts the patient id from the feature file and adds it to the
%   original list
%   
%   Input:
%           fileList    :   list of files, each row represents a new file
% 
%   Output:
%           fileList    :   list of files with the patient IDs extracted.
% 
%   The assumption here is that the feature file would be of the form
%   fv_<patient ID>_<condition ID>_<session ID>.mat

for P=1:length(fileList)
    fname = fileList{P,1};
    fname = strsplit(fname,'/');
    fname = fname{end};
    fname = strsplit(fname,'_');
    fname = fname{2};
    fileList{P,2} = str2num(fname);
    fileList{P,3} = false;
end

end

