%%
% this function is the driver for running all the tests on the dataset
% before running this file make sure to run the TestDatatset.m to ensure
% that the tests are correctly generated
%
%
clear;
load test_files
debug = true;
beeps = [];

%%
files = beep_files.keys;
for x = 1:length(files)
    file = files{x};
    %beeps = buzz_files(file) * 16000;
   
    fprintf('Processing file %s\n', file);
    signal = raw_sound(sprintf('dataset/%s.audio', file));
    signal = scale_signal(signal, -1, 1);
    audiowrite('signal.wav', signal, 16000);
    
    %[locations, pks, newsignal] = remove_beeps(signal, debug);        
%     if (debug)
%         ys = ones(size(beeps)) * max(pks);
%         plot(beeps, ys, 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k');
%     end
    
    %[locations, pks, newsignal] = remove_buzz(signal, debug);        
    newsignal = signal;
    audiowrite(sprintf('output/%s.wav', file), newsignal, 16000);

   
    
%    d = beeps - locations;
end

