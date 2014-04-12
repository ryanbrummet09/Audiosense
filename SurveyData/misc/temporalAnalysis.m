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
unAlteredSize = size(charArray,2);
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
      end
   end
end
%find the number of users
users = str2double(unique(cellArray(:,1)));
%create context array for users
userContexts = zeros([140*size(users,1), 18]);
index = 1;
for a = 1 : size(users,1)
    for i = 1 : 7
        for k = 8 : 12
            for j = 13 : 16
                userContexts(index,i) = 1;
                userContexts(index,k) = 1;
                userContexts(index,j) = 1;
                userContexts(index,18) = a;
                index = index + 1;
            end
        end
    end
end
%get demographic info
dem = fopen('Demographics.csv');
fgetl(dem);
charArray = fgetl(dem);
index = 1;
while (ischar(charArray))
   charArray = strsplit(charArray, ',');
   for k = 1 : size(charArray,2)
      demArray(index, k) = charArray(1,k); 
   end
   charArray = fgetl(dem);
   index = index + 1;
end
%get quantity of each context
noFilter = true;
temporalPerceptionArray = zeros([1,141,size(users,1)]);
for k = 1 : size(cellArray,1)
   if str2double(cellArray(k,7)) == 1  %|| noFilter%filters usr or program init samples
        ac = str2double(cellArray(k,8));
        lc = str2double(cellArray(k,9));
        nz = str2double(cellArray(k,26));
        %sp = 16, le = 17, ld = 18, ld2 = 19, lcl = 20, ap = 23, qol = 24,
        %im = 25, st = 27
        perceptionVal = str2double(cellArray(k,16));
        usrNum = str2double(cellArray(k,1));
        if num2str(cell2mat(demArray(usrNum, 2))) == 'F' || noFilter  %demographic filter
            if usrNum ~= 1
                userIndex = ((usrNum - 1) * 140);  %used for indexing
            else
                userIndex = 0;
            end
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
            userIndex = ac + lc + nz + userIndex;
            userContexts(userIndex,17) = userContexts(userIndex,17) + 1;
            contexts(index,17) = contexts(index,17) + 1;
            if perceptionVal > -1
                temporalPerceptionArray(userContexts(userIndex,17),index,usrNum) = perceptionVal;
                temporalPerceptionArray(userContexts(userIndex,17), 141, usrNum) = temporalPerceptionArray(userContexts(userIndex,17), 141, usrNum) + 1;
            else
                temporalPerceptionArray(userContexts(userIndex,17),index,usrNum) = 0;
            end
        end
   end
end
perceptionSumMatrix = zeros([size(temporalPerceptionArray,1),size(temporalPerceptionArray,2)]);
for k = 1 : size(users,1)
    perceptionSumMatrix = perceptionSumMatrix + temporalPerceptionArray(:,:,k);
end
for k = 1 : size(perceptionSumMatrix,1)
    if perceptionSumMatrix(k,141) < 5
        output(k) = (sum(perceptionSumMatrix(k,[1:140]))) / perceptionSumMatrix(k,141);
    else
        lineOutput(k) = (sum(perceptionSumMatrix(k,[1:140]))) / perceptionSumMatrix(k,141);
        output(k) = (sum(perceptionSumMatrix(k,[1:140]))) / perceptionSumMatrix(k,141);
    end
end
instance = [1:size(lineOutput,2)];
mdl = polyfit(instance,lineOutput,1);
for k = 1 : size(lineOutput,2)
   line(k) = k * mdl(1) + mdl(2); 
end
hold all;
plot(output,'g');
title({'Speech Perception by Instance','linear regression accounts for only instances with 5 or more samples'});
xlabel('Instance');
ylabel('Speech Perception');
plot(line,'r');
hold off;