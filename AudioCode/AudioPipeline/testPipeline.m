[fname,pname] = uigetfile('*.audio','MultiSelect','on');
%H = {};
%L = {};
W = {};
P1 = {};
L = {};
for P=1:length(fname)
    %length(fname)
    %if length(fname) == 1
     %   f = strcat(pname,fname);
    %else
    f = strcat(pname,fname{P});
    %end
    audioSignal = preProcess(f);
    frames = framing(audioSignal,16000,0.02);
    %HEFrames = [];
    %LE = [];
    pw = [];
    ww = [];
    lw = [];
    K=1;
    for Q=1:length(frames)
        lastFrameOfFile = false;
        if frames(Q,:) == frames(end,:)
            lastFrameOfFile = true;
        end
        s = sprintf('%d,%d',P,Q);
        disp(s);
        [HEF,LE] = frameProcessing(frames(Q,:),150);
        [p,w,l] = windowing(HEF,LE,8000,lastFrameOfFile);
        pw(end+1) = p;
        if p
            s = sprintf('Window! %d,%d',length(w),l);
            disp(s);
            ww(end+1,:) = w;
            lw(end+1) = l;
        end
        %if length(He)==1
        %    He(2:320)=0;
        %end
        %HEFrames(end+1,:) = He;
    end
    %H{P} = HEFrames;
    %L{P} = LE;
    W{P} = ww;
    P1{P} = pw;
    L{P} = lw;
end