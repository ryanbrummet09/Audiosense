%make sure to run measureMatrixSparcity2a.m first as it extracts data
%creates variables that are needed by this script

%we will normalize the extracted data by normalizing across contexts.
%First we find the average subjective ratings for each attribute of every
%context.  Then we find the standard deviation in the same manner.  We
%store the data in the contextNorms form contextID, spAVG, spSTD, leAVG, 
%leSTD, ldAVG,ldSTD, ld2AVG, ld2STD, lclAVG, lclSTD, apAVG, apSTD, qolAVG, 
%qolSTD, imAVG, imAVG, stAVG, stSTD

contextNorms = zeros([size(contextIndexes,1),19]);
contextNorms(:,1) = contextIndexes(:,1);
clearvars temp;
for k = 1: size(contextIndexes,1)
    temp(1,:) = unique(contextIndexes(k,[2:size(contextIndexes,2)]));
    temp = temp(temp ~= 0);
    contextID = contextIndexes(k,1);
    index = find(contextNorms(:,1) == contextID);
    if size(temp,1) > 1
        for i = 1 : size(temp,1)
            for j = 1 : 9
                tempMatrix(i,j) = extractedData(temp(1,i),13 + j);
            end
        end
        
        for i = 1 : 9
            count = 1;
            for j = 1 : size(tempMatrix,1)
                if tempMatrix(j,i) >= 0
                    temp2(count) = tempMatrix(j,i);
                    count = count + 1;
                end
            end
            contextNorms(index,(2 * i)) = mean(temp2);
            contextNorms(index,(2 * i) + 1) = std(temp2);
            clear temp2;
        end
    else
        for i = 1 : 9
            contextNorms(index,(2 * i)) = temp(1,1);  %one value => average is that value
            contextNorms(index,(2 * i) + 1) = 1; %must be one so that z score is not undefined
        end
    end
    clearvars tempMatrix temp;
end
clearvars temp;
for k = 1 : size(extractedData,1)
    if ~(extractedData(k,13) >= 0)
        edk13 = 0;
    else
        edk13 = extractedData(k,13);
    end
    if ~(extractedData(k,12) >= 0)
        edk12 = 0; 
    else
        edk12 = extractedData(k,12);
    end
    if ~(extractedData(k,11) >= 0)
        edk11 = 0; 
    else
        edk11 = extractedData(k,11);
    end
    if ~(extractedData(k,10) >= 0)
        edk10 = 0; 
    else
        edk10 = extractedData(k,10);
    end
    if ~(extractedData(k,9) >= 0)
        edk9 = 0; 
    else
        edk9 = extractedData(k,9);
    end
    if ~(extractedData(k,8) >= 0)
        edk8 = 0; 
    else
        edk8 = extractedData(k,8);
    end
    if ~(extractedData(k,7) >= 0)
        edk7 = 0; 
    else
        edk7 = extractedData(k,7);
    end
    if ~(extractedData(k,6) >= 0)
        edk6 = 0; 
    else
        edk6 = extractedData(k,6);
    end
    if ~(extractedData(k,5) >= 0)
        edk5 = 0; 
    else
        edk5 = extractedData(k,5);
    end
    if ~(extractedData(k,4) >= 0)
        edk4 = 0; 
    else
        edk4 = extractedData(k,4);
    end
    temp = edk13 + (edk12 * 100) + (edk11 * 1000) + (edk10 * 10000) + (edk9 * 100000) + (edk8 * 1000000) + (edk7 * 10000000) + (edk6 * 100000000) + (edk5 * 1000000000) + (edk4 * 10000000000);
    temp = find(contextNorms(:,1) == temp);
    extractedData(k,14) = (extractedData(k,14) - contextNorms(temp, 2)) / contextNorms(temp, 3);
    extractedData(k,15) = (extractedData(k,15) - contextNorms(temp, 4)) / contextNorms(temp, 5);
    extractedData(k,16) = (extractedData(k,16) - contextNorms(temp, 6)) / contextNorms(temp, 7);
    extractedData(k,17) = (extractedData(k,17) - contextNorms(temp, 8)) / contextNorms(temp, 9);
    extractedData(k,18) = (extractedData(k,18) - contextNorms(temp, 10)) / contextNorms(temp, 11);
    extractedData(k,19) = (extractedData(k,19) - contextNorms(temp, 12)) / contextNorms(temp, 13);
    extractedData(k,20) = (extractedData(k,20) - contextNorms(temp, 14)) / contextNorms(temp, 15);
    extractedData(k,21) = (extractedData(k,21) - contextNorms(temp, 16)) / contextNorms(temp, 17);
    extractedData(k,22) = (extractedData(k,22) - contextNorms(temp, 18)) / contextNorms(temp, 19);
end

%scale data so that values are on the range [0,1].  We take the minimum
%value to be the minimum observed value in our data set for a particular
%attribute and likewise for the maximum value.
for k = 1 : 9
    temp = extractedData(:,(13 + k));
    temp2 = temp(temp >= 0);
    temp3 = temp(temp <  0);
    temp = [temp2',temp3'];
    minimum(k) = min(temp);
    maximum(k) = max(temp);
end
for k = 1 : size(extractedData,1)
   for i = 1 : 9
      extractedData(k,(13 + i)) = (extractedData(k,(13 + i)) - minimum(i)) / (maximum(i) - minimum(i));
   end
end
% clearvars temp temp2
% temp = find(contextIndexes(:,1) == contextQuantity(indices(1),1))
% temp2 = unique(contextIndexes(temp,:))
% temp2 = temp2((temp2 > 0) & (temp2 < 10000000))
% hist(extractedData(temp2,19),100)
clearvars ac ans charArray cnd conditions count edk10 edk11 edk12 edk13 edk4 edk5 edk6 edk7 edk8 edk9 fid i index j k lc nextUrs nl nz rs temp temp2 temp3 tf thisUsr tl tlSub user userIndex vc;