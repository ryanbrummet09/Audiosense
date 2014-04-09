%Author Ryan Brummet
%University of Iowa

function [ inputData ] = normalizeAcrossUsers( inputData, userSet )
%Normalizes data across users.  That is the average rating and std's for
%each user per attribute is found and is used to normalize each user sample

%  inputData (input matrix): patient data

%  userSet (input vector): vector of unique user id's

%  returnedData (output matrix): normalized data
    
    %first we will find the average rating for each attribute for each user.
    %Then we will find the standard deviation in the same manner.  These values
    %will be stored in userNorms which will have the form userID, spAVG, spSTD,
    %leAVG, leSTD, ldAVG, ldSTD, ld2AVG, ld2STD, lclAVG, lclSTD, apAVG, apSTD,
    %qolAVG, qolSTD, imAVG, imSTD, stAVG, stSTD
    userNorms = zeros(size(userSet,2),19);
    userNorms(:,1) = userSet;

    %we will iterate through the inputData matrix once for each user.  While
    %inefficient, it is simplier to program. Since the matrix is relatively
    %small the inefficiency shouldn't make much of a difference in runtime
    for k = 1 : size(userSet,2)
        tempIndex = 1;
        for j = 1 : size(inputData,1)
            if inputData(j,1) == userSet(1,k)
                temp(tempIndex,:) = inputData(j,:);
                tempIndex = tempIndex + 1;
            end
        end
        for m = 1 : 9
            tempIndex = 1;
            temp2(1) = NaN;
            for j = 1 : size(temp,1)
                if temp(j,13 + m) >= 0
                    temp2(tempIndex) = temp(j,13 + m);
                    tempIndex = tempIndex + 1;
                end
            end
            if temp2(1) >= 0
                userNorms(k,m * 2) = mean(temp2);
                userNorms(k,(m * 2) + 1) = std(temp2);
            else
                userNorms(k,m * 2) = NaN;
                userNorms(k,(m * 2) + 1) = NaN;
            end
        
            clearvars temp2;
        end
        clearvars temp;
    end
    
    %here we normalize the data
    for k = 1 : size(inputData,1)
        index = find(userNorms(:,1) == inputData(k,1));
        for j = 1 : 9
            inputData(k,13 + j) = (inputData(k,13 + j) - userNorms(index,2 * j)) / userNorms(index,(2 * j) + 1);
        end
    end
    
    %here we rescale the data between 0 and 100
    %minimum and maximums are found per attribute and not globally for all
    %attributes
    for k = 1 : 9
        minimum(k) = min(inputData(:,13 + k));
        maximum(k) = max(inputData(:,13 + k));
    end
    for k = 1 : size(inputData,1)
        for j = 1 : 9
            inputData(k,13 + j) = 100 * (inputData(k,13 + j) - minimum(j)) / (maximum(j) - minimum(j));
        end
    end
end

