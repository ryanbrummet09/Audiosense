% To run the pipeline in parallel, the user would need the list of all
% audio files in a cell array, each element is the path to a file.
addpath ../;
load('fileList');
matlabpool open;
parfor P=1:length(fileList)
    s = sprintf('Looking at %s, \nIndex:%d',fileList{P},P);
    disp(s);
    featureVector = perFilePipeline(12,16000,fileList{P});
    if isempty(featureVector)
        continue;
    end
    [p,c,s] = getInfo(fileList{P});
    fname = strcat('fileFeatures/fv_',num2str(p),'_',num2str(c),'_',num2str(s));
    saveV(featureVector,fname);
end
matlabpool close;
exit;