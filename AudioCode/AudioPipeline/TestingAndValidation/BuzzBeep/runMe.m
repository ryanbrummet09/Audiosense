function [ buzzBeepLocations,specs,toCheck ] = runMe( Frequency )
%RUNME run this to validate the buzz and beeps
%   See also VERIFYBUZZBEEPFILTER, SPECSEN, TPFNFP

load('buzzBeepValidationVariables');
buzzBeepLocations= verifyBuzzBeepFilter( Frequency );
specs= specSen( buzzBeepLocations, toCheck );

end

