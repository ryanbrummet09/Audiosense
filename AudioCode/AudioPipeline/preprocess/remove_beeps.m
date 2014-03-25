function [ locs, pks, new_signal ] = remove_beeps( signal, debug_flag )
%REMOVEBEEP Removes beeps from data
%   signal - the sound data
%   template - the beep file
%

if (nargin == 2)
    dflag = debug_flag;
else
    dflag = false;
end

persistent beepTemplate;
persistent beepBandPass;

if (isempty(beepBandPass))
    beepBandPass = beep_bandpass();
end

if (isempty(beepTemplate))
    beepTemplate = raw_sound('beep.raw');
    beepTemplate = scale_signal(beepTemplate, -1, 1);
    beepTemplate = filter(beepBandPass, beepTemplate);
    
end

% scale the signals
orig = signal;
signal = scale_signal(signal, -1, 1);

% compress the input signal
comp = -.95;
a = 0.4;
signal = compexp(signal, comp, a); %call compressor
signal = scale_signal(signal, -1, 1);

% filter the signal and the template
signal = filter(beepBandPass, signal);

[c, lags] = xcorr(signal, beepTemplate);
ix = find(lags == 0);
c = c(ix:end);

sz = .3 * 16000;
guard = ceil(.1 * 16000);
[pks, locs] = findpeaks(c, 'MINPEAKHEIGHT', 50, 'MINPEAKDISTANCE', sz);


keep = true(size(signal));
for x = 1:length(locs)
    keep(locs(x) - guard :locs(x) + sz + guard) = false;
end

new_signal = orig(keep);

if (dflag)
    figure()
    plot(c, 'b')
    hold on
    plot(locs, pks, 'ro')
end
end

