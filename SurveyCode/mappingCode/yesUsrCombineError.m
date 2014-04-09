%Author Ryan Brummet
%University of Iowa

function [ mapError ] = yesUsrCombineError( mapErrorTemp )

%mapErrorTemp (input 3dArray): gives the error matrix for each user.  See
%       mapError for more info.

%mapError (output matrix): gives the average error across users.  the mean 
%       is column 1, the median is column 2, and the max is column 3.  Row 
%       1 is sp, 2 is le, 3 is ld, 4 is ld2, 5 is lcl, 6 is ap, 7 is qol, 
%       8 is im, and 9 is st.  See the description in audioSurveyProc.m for
%       my in depth information

for row = 1 : size(mapErrorTemp,1)
    for column = 1 : size(mapErrorTemp,2)
        index = 1;
        temp(1) = NaN;
        for user = 1 : size(mapErrorTemp,3) 
            if mapErrorTemp(row,column,user) >= 0
                temp(index) = mapErrorTemp(row,column,user); 
                index = index + 1;
            end
        end
        if temp(1) >= 0
            mapError(row,column) = mean(temp);
        else
            mapError(row,column) = NaN;
        end
        clearvars temp;
    end
end

