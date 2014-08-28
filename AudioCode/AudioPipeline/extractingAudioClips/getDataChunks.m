function dataChunks = getDataChunks( AudioFileClips, audioFileDetails )
%GETDATACHUNKS script to extract data chunks
%   Detailed explanation goes here
addpath ../;
%% get the unique details
pcs = AudioFileClips.pcsList;
pcs = unique(pcs);
%% start extracting the audioClips
for P=1:length(pcs)
    t = pcs{P};
    t = strsplit(t,'_');
    pid = str2num(t{1});
    cid = str2num(t{2});
    sid = str2num(t{3});
    st = AudioFileClips.starts(AudioFileClips.patient==pid & ...
        AudioFileClips.condition==cid & AudioFileClips.session==sid);
    en = AudioFileClips.ends(AudioFileClips.patient==pid & ...
        AudioFileClips.condition==cid & AudioFileClips.session==sid);
    lbls = AudioFileClips.label(AudioFileClips.patient==pid & ...
        AudioFileClips.condition==cid & AudioFileClips.session==sid);
    fpath = audioFileDetails.filepath(audioFileDetails.patient==pid & ...
        audioFileDetails.condition==cid & audioFileDetails.session==sid);
    data = getSoundData(fpath{1});
    disp(sprintf('%d_%d_%d',pid,cid,sid));
    dataChunks = getSoundDataChunk(data,st,en,16000);
    [r, c] = size(dataChunks);
    for Q=1:r
        fname = sprintf('chunks/%d_%d_%d_%d_%s.audio',pid,cid,sid,Q,lbls{Q});
        fid = fopen(fname,'w');
        disp(sprintf('Writing to %s',fname));
        fwrite(fid,dataChunks{Q},'short',0,'l');
        fclose(fid);
    end
end
end

