function [ locs, pks, new_signal ] = remove_buzz( signal, debug_flag )
%REMOVEBEEP Removes beeps from data
%   signal - the sound data
%   template - the beep file
%

if (nargin == 2)
    dflag = debug_flag;
else
    dflag = false;
end

persistent buzzTemplate;
persistent buzzBandPass;

if (isempty(buzzBandPass))
    buzzBandPass = buzz_bandpass();
end

if (isempty(buzzTemplate))
    buzzTemplate = raw_sound('buzz.raw');
    length(buzzTemplate);
    buzzTemplate = scale_signal(buzzTemplate, -1, 1);
    buzzTemplate = filter(buzzBandPass, buzzTemplate);
    
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
signal = filter(buzzBandPass, signal);

[c, lags] = xcorr(signal, buzzTemplate);
ix = find(lags == 0);
c = c(ix:end);

sz = length(buzzTemplate);
[pks, locs] = findpeaks(c, 'MINPEAKHEIGHT', 200, 'MINPEAKDISTANCE', sz);


guard = ceil(.1 * 16000);
keep = true(size(signal));

for x = 1:length(locs)
    ll = locs(x)-guard;
    if ll <= 0
        ll = 1;
    end
    ul = locs(x) + sz + guard;
    if ul > length(orig)
        ul = length(orig);
    end
    keep(ll:ul) = false;
end

% for x = 1:length(locs)
%     keep(locs(x) - guard :locs(x) + sz + guard) = false;
% end

new_signal = orig(keep);

if (dflag)
    figure()
    plot(c, 'b')
    hold on
    plot(locs, pks, 'ro')
end
end

