%Author Ryan Brummet
%University of Iowa

function [ returnedData, userSampleCount, userIndexSet ] = ...
     testSurveyDuration( inputData, minSurveyPercent, userSet )
%Examines extracted patient data and removes samples that are not within
%a certain percentage of average sample duration of the user to which the
%sample belongs.  Also records the number  
%of samples per user.

%inputData is data that was removed using the extractAndProcData function

%given the average amount of time that a user spends taking a survey, we
%find the amount of time that is minSurveyPercent of that average.  For
%example if the average amount of time is 100 seconds and
%minSurveyPercentage is 20%, all samples for that user must between 80 and 
%120 seconds.  If minSurveyPercentage is 34%, all samples for that user 
%must be between 66 and 134 seconds.

%inputData (input matrix): input patient data

%minSurveyPercentage (input int): minimum percent of user sample average
%       duration.  duration must be in the interval 
%       [average - duration*this, average + duration*this]

%userSet (input vector): gives a vector of all unique id's in the inputData
%       matrix

%returnedData (output matrix): input data with samples removed that don't
%       mean minimum duration requirement

%userSampleCount (output matrix): gives the number of samples for each
%       user.  This is information that will be needed in another function.

%userIndexSet (output matrix): gives the index of each user's samples in
%       the input data matrix


    %prevents the function from continuing if extractedData is empty.  This
    %could happen because of user error when addiing params to the function
    %call
    if size(inputData,1) < 2
        error('extractedData contains zero samples.  Check your function input');
    end
    
    if minSurveyPercent == 0
        returnedData = inputData;
        return;
    end
    if minSurveyPercent < 0 || minSurveyPercent > 100
        error('Invalid value for minSurveyPercent'); 
    end
    
    %remove samples that don't make duration requirement
    %it would be more efficient to run this elsewhere but it was easier 
    %to program this way.  Because of the small size of inputData this 
    %shouldn't be a problem.
    userDurations = zeros(size(userSet,2),2);
    userSampleCount = zeros(size(userSet,2),2);
    userSampleCount(:,1) = userSet;
    for k = 1 : size(inputData,1)
        index = find(userSampleCount(:,1) == inputData(k,1));
        userSampleCount(index,2) = userSampleCount(index,2) + 1;
        userDurations(index,userSampleCount(index,2)) = inputData(k,23);
        userIndexSet(index,userSampleCount(index,2)) = k;
    end
    userDurationAverage = zeros(size(userSet,2),2);
    userDurationAverage(:,1) = userSet(1,:);
    for k = 1 : size(userSet,2)
        userDurationAverage(k,2) = mean(userDurations(k,1:userSampleCount(k,2)));
    end
    clearvars userSampleCount userIndexSet
    userSampleCount = zeros(size(userSet,2),2);
    userSampleCount(:,1) = userSet;
    index = 1;
    for k = 1 : size(inputData)
        userIndex = find(userDurationAverage(:,1) == inputData(k,1));
        minimum = userDurationAverage(userIndex,2) * (minSurveyPercent / 100);
        maximum = 2 * userDurationAverage(userIndex,2) - minimum;
        if (inputData(k,23) >= minimum) & (inputData(k,23) <= maximum)
            index2 = find(userSampleCount(:,1) == inputData(k,1));
            userSampleCount(index2,2) = userSampleCount(index2,2) + 1;
            userIndexSet(index2,userSampleCount(index2,2)) = index;
            returnedData(index,:) = inputData(k,1:22);
            index = index + 1;
        end
    end
end

