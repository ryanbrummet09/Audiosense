function [ l_buzz,l_beep, newSignal ] = buzzBeepFilter( signal, reverseRemovalOrder )
%BUZZBEEPFILTER Removes the buzz and beep from the frame
%   BUZZBEEPFILTER Removes the buzz and beeps introduced in the audio due
%   to the haptic and sonus feedback mechanism of AudioSense. This filter
%   takes in the frame as input and returns a new frame with the buzzes and
%   the beeps removed. The order of removal is Buzz then Beep by default,
%   it can be reversed by setting the removalOrder flag to true.

if nargin == 1
    [l_buzz,p1,f1] = remove_buzz(signal);
    [l_beep,p2,f2] = remove_beeps(f1);
elseif nargin == 2
    if reverseRemovalOrder == true
        [l_buzz,p1,f1] = remove_beeps(signal);
        [l_beep,p2,f2] = remove_buzz(f1);
    else
        [l_buzz,p1,f1] = remove_buzz(signal);
        [l_beep,p2,f2] = remove_beeps(f1);
    end
else
    s = sprintf('There are either too few or too many arguments! Returning original frame');
    warning(s);
    f2 = signal;
end

newSignal = f2;

end

