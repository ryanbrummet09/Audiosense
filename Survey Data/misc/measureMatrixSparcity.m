clc;
clearvars;
noFilter = true;
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
%find the number of each context
totalSamples = 0;
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
for k = 1 : size(cellArray,1)
   if str2double(cellArray(k,7)) == 1  || noFilter%filters usr or program init samples
        ac = str2double(cellArray(k,8));
        lc = str2double(cellArray(k,9));
        nz = str2double(cellArray(k,26));
        thisUser = str2double(cellArray(k,1));
        if num2str(cell2mat(demArray(thisUser, 2))) == 'F' || noFilter  %demographic filter
            totalSamples = totalSamples + 1;
            if thisUser ~= 1
                thisUser = ((thisUser - 1) * 140);
            else
                thisUser = 0;
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
            userIndex = ac + lc + nz + thisUser;
            contexts(index,17) = contexts(index,17) + 1;
            userContexts(userIndex,17) = userContexts(userIndex,17) + 1;
        end
   end
end
%extract occurances, sort largest to smallest, plot
for k = 1 : size(contexts,1)
   overallAmount(k) = contexts(k,17);
end

[overallAmount,indices] = sort(overallAmount,'descend');
%plot(overallAmount);
subSection = userContexts([1:140],17);
subSection = subSection(indices);
userContexts([1:140],17) = subSection;
subplot(2,2,1);
plot(subSection);
hold all;
for k = 2 : size(users,1)
   startIndex = (140 * (k - 1)) + 1;
   endIndex = 140 * k;
   subSection = userContexts([startIndex:endIndex],17);
   subSection = subSection(indices);
   userContexts([startIndex:endIndex],17) = subSection;
   plot(subSection)
end
plot(overallAmount)
title('Normal Context by Quantity');
axis([0,140,0,overallAmount(1)+100]);
xlabel('Context');
ylabel('Quantity');
hold off;


for k = 1 : size(users,1)
   startIndex = (140 * (k - 1)) + 1;
   endIndex = 140 * k;
   hold all;
   subplot(2,2,2);
   semilogy(userContexts([startIndex:endIndex],17))
end
semilogy(overallAmount)
title('Logarithimic Context by Quantity');
axis([0,140,0,overallAmount(1)+100]);
xlabel('Context');
ylabel('Quantity');
hold off;
for k = 1 : size(overallAmount,2)
   overallAmountPMF(k) = overallAmount(k) / totalSamples; 
end
subplot(2,2,3);
stem(overallAmountPMF,'fill')
title('PMF Overall Context')
axis([0,140,0,.2]);
xlabel('Context');
ylabel('Probability');
overallAmountCDF(1) = overallAmountPMF(1);
for k = 2 : size(overallAmount,2)
   overallAmountCDF(k) = overallAmountCDF(k-1) + overallAmountPMF(k);
end
xvals = [1:140];
xvals2 = [2:141];
subplot(2,2,4)
hold all;
scatter(xvals,overallAmountCDF, 16,'fill','blue');
scatter(xvals2,overallAmountCDF,16,'blue');
for k = 1 : size(overallAmount,2) - 1
   plot([xvals(k),xvals2(k)],[overallAmountCDF(k),overallAmountCDF(k)], 'blue'); 
end
hold off;
title('CDF Overall Context');
axis([0,140,0,1]);
xlabel('Context');
ylabel('Probability');
%plot user x quantity of highest context bar graph

figure;
average = zeros([1,4]);
for k = 1 : 20
    barInfo1(k) = userContexts(((k-1) * 140) + 1,17);
    barInfo2(k) = userContexts(((k-1) * 140) + 2,17);
    barInfo3(k) = userContexts(((k-1) * 140) + 3,17);
    barInfo4(k) = userContexts(((k-1) * 140) + 4,17);
end    
subplot(2,2,1);
bar(barInfo1);
title('Most Common Context');
xlabel('User');
ylabel('Top Context Quantity');
subplot(2,2,2);
bar(barInfo2);
title('Second Most Common Context');
xlabel('User');
ylabel('Second Context Quantity');
subplot(2,2,3);
bar(barInfo3);
title('Third Most Common Context');
xlabel('User');
ylabel('Third Context Quantity');
subplot(2,2,4);
bar(barInfo4);
title('Fourth Most Common Context');
xlabel('User');
ylabel('Fourth Context Quantity');
%find number of samples per user
userAmount = zeros(20);
for k = 1 : 20
    for i = 1 : 140
       userAmount(k) = userAmount(k) + userContexts(((k - 1)*140 + i),17); 
    end
end
figure;
bar(userAmount);
title('Surveys per User');
ylabel('Number of Surveys');
xlabel('User');
axis([0,20,0,500]);
