function [ buzzBeepLocations ] = verifyBuzzBeepFilter( Frequency )
%VERIFYBUZZBEEPFILTER returns the buzz and beep locations
%   takes as input the sampling frequency, the output is a cell array with
%   each row as follows {[pid,cid,sid], [beep ranges in seconds], [buzz
%   ranges in seconds]}

addpath preprocess;
[fname,pname] = uigetfile('*.audio','MultiSelect','on');
buzzBeepLocations = {};
b_len = length(getSoundData('beep.raw'));
z_len = length(getSoundData('buzz.raw'));
for P=1:length(fname)
    bp = [];    bz = [];
    f = strcat(pname,fname{P});
    [pid,cid,sid] = getInfo(f);
    signal = getSoundData(f);
    [l_beep,p_beep,s_beep] = remove_beeps(signal);
    [l_buzz,p_buzz,s_buzz] = remove_buzz(signal);
    bp(:,1) = l_beep - b_len;   bz(:,1) = l_buzz - z_len;
    bp(:,2) = l_beep + b_len;   bz(:,2) = l_buzz + z_len;
    bp = bp ./ Frequency;   bz = bz ./ Frequency;
    buzzBeepLocations{end+1,1} = [pid,cid,sid];
    buzzBeepLocations{end,2} = bp;
    buzzBeepLocations{end,3} = bz;
end
end

