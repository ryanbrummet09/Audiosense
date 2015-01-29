% Ryan Brummet
% University of Iowa
%
% This function builds a libSVM/libLinear model for the given param(s).  
% Tuning parameter are gamma and cost.  This function operates by
% seperating the input dataset by the given param(s) and calling
% buildPoolDataMDL on the extracted data subset.  For the most part error
% handling occurs in buildPoolDataMDL.  Notice also that nothing is
% returned by this function.  Instead it is required that users provided a
% save location.
%
% Params: 
%    struct: inputStruct
%       fields: 
%           string: libLocation - location of libSVM library
%           int: libToUse - 1 to use libSVM library syntax. 2 to use
%                           liblLinear library syntax.  Default is libSVM.
%           cell array: dirsToPath - location of directories to add to
%                                    path.  Add by column NOT row.
%           string: saveLocation - location to save results; if not present
%                                  results are only returned, not saved.
%                                  Include the full name you wish to use
%                                  but do not include extension.
%           string: dataLocation - location of dataset (must be table named
%                                  dataTable saved at this .mat location).
%                                  If it is not present the data field must
%                                  be present.
%           table: data - input dataset.  If not present dataLocation must
%                         be present.
%           cell array: response - name of the response being predicted.
%                                  If not the last column of dataTable an
%                                  error is thrown.
%           int: numCores - gives the number of cores to use for parfor.
%                           Default is 1.
%           bool: makePlot - if true a graph is created. default is true.
%                            for this to run it must also be true that
%                            crossValFolds == 5
%           cell array: groupVars - gives predictors used to stratify folds
%           int: seed - gives the seed value for the RNG
%           int: maxIterCount - gives the max "zoom ins" for grid search.
%                               default is 10
%           int: crossValFolds - gives the number of inner/outer cross
%                                validation folds. default is 5
%           array: startGammaValues - gives initial grid search range for
%                                     gamma.  Must be column array not row
%           array: startCostValues - gives initial grid search range for
%                                    cost.  Must be column array not row
%           bool: allowGridSearchEdgeVals - if true values at the edge of
%                                           the grid search, search range
%                                           are allowed (no error thrown).
%                                           Default is false
%           int: degree - gives degree of SVM model. default is 1
%           int: kernel - gives kernal/solver using either libSVM or
%                         libLinear syntax.  Default is 2 (RBF) for libSVM
%                         and 11 (L2-regularized L2-loss support vector 
%                         regression, primal) for libLinear.
%           cellArray: toRemoveCompletely - cell array of predictor names
%                                           to completely remove.
%           cellArray: toRemoveModel - cell array of predictor names to
%                                      omit from created model(s).  This
%                                      field is primarily used to allow the
%                                      user of this function to remove a
%                                      variable from a model but still
%                                      allow it to be used for other
%                                      functions.  For example, you may
%                                      want to not include a particular
%                                      variable in a model but still use it
%                                      to stratify your dataset.  In this
%                                      case you must include the variable
%                                      in question in this field and
%                                      groupVars.  Finally, notice that all
%                                      predictor names included here must
%                                      be categorical (surveyPreds).
%           function handle: scaleFunc - scales the audio predictors according
%                                    to the passed function handle.  This
%                                    function takes as input the whole set
%                                    of audio features as once, not just
%                                    one at a time.  Notice also that
%                                    survey features are not passed, only
%                                    audio features (one does not need to
%                                    worry about inadvertently scaling
%                                    categorical survey features).  This
%                                    scaling is applied globally rather
%                                    than per training set: either inner or
%                                    outer.
%           int: scaleLower - gives the lower value of the scaling range
%                             created by scaleFunc.  default is 0.
%           int: scaleUpper - gives the upper value of the scaling range
%                             created by scaleFunc.  default is 1.
%           cell array: catPreds - gives the names of categorical
%                                  variables in dataTable.  All categorical
%                                  variables are assumed to be described
%                                  numerically (ie 1,2,3,... not
%                                  a,b,c,...).  All categorical variables
%                                  that appear here cannot be included in
%                                  toRemoveCompletely or toRemoveModel.
%           cell array: zeroPreds - gives the names of catPreds that have 0
%                                   as a category
%   cellArray: stratParams - gives a list of predictor variables that will
%                            be used to stratify the input dataset.  Each
%                            individual dataset is then passed to
%                            buildPoolDataMDL using the values stored in
%                            the fields of inputStruct.  The values in this
%                            param are assumed to be categorical (weird
%                            effects are likely if they are not).
%   cellArray: toInclude - each colument of toInclude corresponds to
%                          stratParams.  Each column of toInclude stores an
%                          array of values to include for the corresponding
%                          value in stratParams.  Values that are not
%                          present are removed.  If all is given as one of
%                          the values for a column all predictors are
%                          included.

function [ ] = buildMDLPerParam( inputStruct, stratParams, toInclude )
    % handle present and missing field values
    if isfield(inputStruct,'dirsToPath')
        temp = inputStruct.dirsToPath;
        for k = 1 : size(temp,2)
            addpath(genpath(temp{k})); 
        end
    end
    if isfield(inputStruct,'saveLocation')
        saveLocation = inputStruct.saveLocation;
    else
        error('You must provide a save location when using buildMDLPerParam'); 
    end
    if isfield(inputStruct,'response')
        response = inputStruct.response; 
    else
        error('You must provide the response you wish to predict');
    end
    if isfield(inputStruct,'dataLocation')
        load(inputStruct.dataLocation);
        temp = dataTable(:,end);
        temp = temp.Properties.VariableNames;
        if ~ismember(temp{1},response)
            error('The last column of the table that you pass to SVMFunc must be either sp, le, ld, ld2, lcl, ap, qol, im, or st'); 
        end
        inputStruct = rmfield(inputStruct,'dataLocation');
    else
        if isfield(inputStruct,'dataset')
            dataTable = inputStruct.dataset;
            temp = dataTable(:,end);
            temp = temp.Properties.VariableNames;
            if ~ismember(temp{1},response)
                error('The last column of the table that you pass to SVMFunc must be either sp, le, ld, ld2, lcl, ap, qol, im, or st'); 
            end
            inputStruct = rmfield(inputStruct,'dataset');
        else
            error('You must either provide the location of the data you wish to use or a dataset');
        end
    end
    if size(toInclude,2) ~= size(stratParams,2)
        error('You must provide a toInclude param that has a corresponding column for each column in stratParams');
    end
    
    uniqueVals = struct;
    for k = 1 : size(stratParams,2)
        tempInclude = toInclude{k};
        if ischar(tempInclude)
            tempInclude = unique(dataTable.(stratParams{k}));
        end
        temp = unique(dataTable.(stratParams{k}));
        temp(~ismember(temp,tempInclude)) = [];
        uniqueVals.(stratParams{k}) = temp;
        dimensions(1,k) = size(uniqueVals.(stratParams{k}),1);
    end
    if size(dimensions,2) == 1
        execArray = zeros([dimensions,1]);
    else
        execArray = zeros(dimensions);
    end
    for k = 1 : numel(execArray)
        subDataTable = dataTable;
        index = cell(1,size(stratParams,2));
        [index{:}] = ind2sub(size(execArray), k);
        index = cell2mat(index);
        subSaveLocation = saveLocation;
        for j = 1 : size(index,2)
            temp = uniqueVals.(stratParams{j});
            subDataTable = subDataTable(temp(index(j)) == subDataTable.(stratParams{j}),:);
            subSaveLocation = strcat(subSaveLocation,stratParams{j},num2str(temp(index(j))));
        end
        inputStruct.dataset = subDataTable;
        inputStruct.saveLocation = subSaveLocation;
        disp(strcat('Running buildPoolDataMDL execution',{' '},num2str(k),{' of '},num2str(numel(execArray))));
        buildPoolDataMDL(inputStruct);
        close all;
    end
end

