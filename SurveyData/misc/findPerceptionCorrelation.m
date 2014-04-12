clc;
clearvars;
%extract data
fid = fopen('ema.csv');
fgetl(fid);
charArray = fgetl(fid);
index = 1;
while(ischar(charArray))
    charArray = strsplit(charArray, ',');
    for i = 1 : size(charArray,2)
        cellArray(index,i) = charArray(1,i);
    end
    charArray = fgetl(fid);
    index = index + 1;
end
%context description (overall, not considering different users)
%ac1,ac2,ac3,ac4,ac5,ac6,ac7,lc1,lc2,lc3,lc4,lc5,nz1,nz2,nz3,nz4,count
%create an array containing each possible context
contexts = zeros([140,17]);
contextIndex = zeros([140,1]);
index = 1;
for i = 1 : 7
   for k = 8 : 12
      for j = 13 : 16
          contexts(index,i) = 1;
          contexts(index,k) = 1;
          contexts(index,j) = 1;
          index = index + 1;
          tempIndex = ((i - 1) * 20) + ((k - 8) * 4) + j - 12;
          for a = 1 : size(cellArray,1)
              corrContexts(a,tempIndex) = NaN;
          end
      end
   end
end
%associate perceptions with contexts
for k = 1 : size(cellArray,1)
    if str2double(cellArray(k,7)) == 1  %filters usr or program init samples
        ac = str2double(cellArray(k,8));
        lc = str2double(cellArray(k,9));
        nz = str2double(cellArray(k,26));
        if ac ~= 1
            ac = ((ac - 1) * 20);
        else
            ac = 0; 
        end
        if lc ~= 1
            lc = ((lc - 1) * 4);
        else
            lc = 0; 
        end
        index = ac + lc + nz;
        if contextIndex(index,1) == -1
            contextIndex(index,1) = 1;
        else
            contextIndex(index,1) = contextIndex(index,1) + 1;
        end
        contexts(index,17) = contexts(index,17) + 1;
        corrContexts(contextIndex(index,1), index) = str2double(cellArray(k,27));
    end
end
%extract occurances, sort largest to smallest
for k = 1 : size(contexts,1)
   overallAmount(k) = contexts(k,17);
end
[overallAmount,indices] = sort(overallAmount,'descend');
corrContexts = corrContexts(:,indices);
subplot(2,2,1);
boxplot(corrContexts(:,1:35),'plotstyle','compact')
xlabel('Context');
ylabel('Satisfaction');
title('Context Ordered By Quantity, Descending');
subplot(2,2,2);
boxplot(corrContexts(:,36:70),'plotstyle','compact','labels',[36:70])
xlabel('Context');
ylabel('Satisfaction');
title('Context Ordered By Quantity, Descending');
subplot(2,2,3);
boxplot(corrContexts(:,71:105),'plotstyle','compact','labels',[71:105]);
xlabel('Context');
ylabel('Satisfaction');
title('Context Ordered By Quantity, Descending');
subplot(2,2,4);
boxplot(corrContexts(:,106:140),'plotstyle','compact','labels',[106:140]);
xlabel('Context');
ylabel('Satisfaction');
title('Context Ordered By Quantity, Descending');