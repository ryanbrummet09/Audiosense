%Ryan Brummet
%University of Iowa

function [ mappedVals ] = evaluatePolynomial( mapCoef, data )
    %map Coef is the coefficients of the mapping function and is ordered in
    %decreasing order.  That is, higher order coeficients are at lower
    %indexes.
    
    mappedVals = polyval(mapCoef,data);
    overMaxIndex = (mappedVals > 100);
    underMinIndex = (mappedVals < 0);
    mappedVals(overMaxIndex) = 100;
    mappedVals(underMinIndex) = 0;
    return;
end

