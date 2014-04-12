%we will use the following attribute designation. ac = 10, lc = 20, tf =
%30, vc = 40, tl = 50, nl = 60, rs = 70, cp = 80, nz = 90.  Furthermore we
%will describe each attribute type by its number.  In other words ac7 = 17,
%nz1 = 91, and nl4 = 64.

%there should be 121019 sets of p values. results stores all our results
%and has the form attribute1, attribute2, acPVal, lcPval, tfPVal, vcPVal,
%tlPVal, nlPVal, rsPVal, cpPVal, nzPVal
results = zeros([121019,11]);
count = 1;


%attribute maximums. bound becuase for all a, a on [1,max].  I have listed
%these values only for programmer clarification (I could have just coded
%the numbers)
acbound = 7; %21 combinations
lcbound = 5; %10
tfbound = 4; %6
vcbound = 3; %3
tlbound = 3; %3
nlbound = 4; %6
rsbound = 3; %3
cpbound = 2; %1
nzbound = 4; %6

for acLowerBound = 1 : acbound
    if acLowerBound ~= acbound
        for acUpperBound = acLowerBound + 1 : acbound
           results(count,1) = 10 + acLowerBound;
           results(count,2) = 10 + acUpperBound;
           [pValues] = getPValueUsingModifiedTTest(1,1,acLowerBound,acUpperBound,extractedData);
           results(count,[3:11]) = pValues;
           count = count + 1;
           clearvars pValues;
        end
    end
    for lcLowerBound = 1 : lcbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 20 + lcLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,2,acLowerBound,lcLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for tfLowerBound = 1 : tfbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 30 + tfLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,3,acLowerBound,tfLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for vcLowerBound = 1 : vcbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 40 + vcLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,4,acLowerBound,vcLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for tlLowerBound = 1 : tlbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 50 + tlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,5,acLowerBound,tlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nlLowerBound = 1 : nlbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 60 + nlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,6,acLowerBound,nlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,7,acLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,8,acLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 10 + acLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(1,9,acLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
end

for lcLowerBound = 1 : lcbound
    if lcLowerBound ~= lcbound
       for lcUpperBound = lcLowerBound + 1 : lcbound
          results(count,1) = 20 + lcLowerBound;
          results(count,2) = 20 + lcUpperBound;
          [pValues] = getPValueUsingModifiedTTest(2,2,lcLowerBound,lcUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for tfLowerBound = 1 : tfbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 30 + tfLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,3,lcLowerBound,tfLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for vcLowerBound = 1 : vcbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 40 + vcLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,4,lcLowerBound,vcLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for tlLowerBound = 1 : tlbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 50 + tlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,5,lcLowerBound,tlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nlLowerBound = 1 : nlbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 60 + nlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,6,lcLowerBound,nlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,7,lcLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,8,lcLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 20 + lcLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(2,9,lcLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
end

for tfLowerBound = 1 : tfbound
    if tfLowerBound ~= tfbound
       for tfUpperBound = tfLowerBound + 1 : tfbound
          results(count,1) = 30 + tfLowerBound;
          results(count,2) = 30 + tfUpperBound;
          [pValues] = getPValueUsingModifiedTTest(3,3,tfLowerBound,tfUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for vcLowerBound = 1 : vcbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 40 + vcLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,4,tfLowerBound,vcLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for tlLowerBound = 1 : tlbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 50 + tlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,5,tfLowerBound,tlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nlLowerBound = 1 : nlbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 60 + nlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,6,tfLowerBound,nlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,7,tfLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,8,tfLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 30 + tfLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(3,9,tfLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
end

for vcLowerBound = 1 : vcbound
    if vcLowerBound ~= vcbound
       for vcUpperBound = vcLowerBound + 1 : vcbound
          results(count,1) = 40 + vcLowerBound;
          results(count,2) = 40 + vcUpperBound;
          [pValues] = getPValueUsingModifiedTTest(4,4,vcLowerBound,vcUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for tlLowerBound = 1 : tlbound
        results(count,1) = 40 + vcLowerBound;
        results(count,2) = 50 + tlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(4,5,vcLowerBound,tlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nlLowerBound = 1 : nlbound
        results(count,1) = 40 + vcLowerBound;
        results(count,2) = 60 + nlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(4,6,vcLowerBound,nlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 40 + vcLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(4,7,vcLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 40 + vcLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(4,8,vcLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 40 + vcLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(4,9,vcLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
end

for tlLowerBound = 1 : tlbound
    if tlLowerBound ~= tlbound
       for tlUpperBound = tlLowerBound + 1 : tlbound
          results(count,1) = 50 + tlLowerBound;
          results(count,2) = 50 + tlUpperBound;
          [pValues] = getPValueUsingModifiedTTest(5,5,tlLowerBound,tlUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for nlLowerBound = 1 : nlbound
        results(count,1) = 50 + tlLowerBound;
        results(count,2) = 60 + nlLowerBound;
        [pValues] = getPValueUsingModifiedTTest(5,6,tlLowerBound,nlLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 50 + tlLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(5,7,tlLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 50 + tlLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(5,8,tlLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 50 + tlLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(5,9,tlLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end    
end

for nlLowerBound = 1 : nlbound
    if nlLowerBound ~= nlbound
       for nlUpperBound = nlLowerBound + 1 : nlbound
          results(count,1) = 60 + nlLowerBound;
          results(count,2) = 60 + nlUpperBound;
          [pValues] = getPValueUsingModifiedTTest(6,6,nlLowerBound,nlUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for rsLowerBound = 1 : rsbound
        results(count,1) = 60 + nlLowerBound;
        results(count,2) = 70 + rsLowerBound;
        [pValues] = getPValueUsingModifiedTTest(6,7,nlLowerBound,rsLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 60 + nlLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(6,8,nlLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 60 + nlLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(6,9,nlLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end    
end

for rsLowerBound = 1 : rsbound
    if rsLowerBound ~= rsbound
       for rsUpperBound = rsLowerBound + 1 : rsbound
          results(count,1) = 70 + rsLowerBound;
          results(count,2) = 70 + rsUpperBound;
          [pValues] = getPValueUsingModifiedTTest(7,7,rsLowerBound,rsUpperBound,extractedData);
          results(count,[3:11]) = pValues;
          count = count + 1;
          clearvars pValues;
       end
    end
    for cpLowerBound = 1 : cpbound
        results(count,1) = 70 + rsLowerBound;
        results(count,2) = 80 + cpLowerBound;
        [pValues] = getPValueUsingModifiedTTest(7,8,rsLowerBound,cpLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 70 + rsLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(7,9,rsLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end     
end

for cpLowerBound = 1 : cpbound
    if cpLowerBound ~= cpbound
        for cpUpperBound = cpLowerBound + 1 : cpbound
           results(count,1) = 80 + cpLowerBound;
           results(count,2) = 80 + cpUpperBound;
           [pValues] = getPValueUsingModifiedTTest(8,8,cpLowerBound,cpUpperBound,extractedData);
           results(count,[3:11]) = pValues;
           count = count + 1;
           clearvars pValues;
        end
    end
    for nzLowerBound = 1 : nzbound
        results(count,1) = 80 + cpLowerBound;
        results(count,2) = 90 + nzLowerBound;
        [pValues] = getPValueUsingModifiedTTest(8,9,cpLowerBound,nzLowerBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end   
end

for nzLowerBound = 1 : nzbound - 1
    for nzUpperBound = nzLowerBound + 1 : nzbound
        results(count,1) = 90 + nzLowerBound;
        results(count,2) = 90 + nzUpperBound;
        [pValues] = getPValueUsingModifiedTTest(9,9,nzLowerBound,nzUpperBound,extractedData);
        results(count,[3:11]) = pValues;
        count = count + 1;
        clearvars pValues;
    end
end

%we will consider two context attributes similar iff the euclidean norm of
%the pValue vector that was found is less than sqrt(.09).  This value was
%picked because each value in the pValue vector will have to be
%approximately +/- .1 or less.

%first we find the euclidean norms
magnitudeResults = zeros([size(results,1),3]);
index = 1;
for k = 1 : length(results)
   magnitudeResults(k,1) = results(k,1);
   magnitudeResults(k,2) = results(k,2); 
   magnitudeResults(k,3) = sqrt(results(k,3)^2 + results(k,4)^2 + results(k,5)^2 + results(k,6)^2 + results(k,7)^2 + results(k,8)^2 + results(k,9)^2 + results(k,10)^2 + results(k,11)^2);
   if magnitudeResults(k,3) <= sqrt(.09) & magnitudeResults(k,3) ~= 0
      relevantResults(index,1) = magnitudeResults(k,1);
      relevantResults(index,2) = magnitudeResults(k,2);
      relevantResults(index,3) = magnitudeResults(k,3);
      index = index + 1;
   end
end
size(unique(relevantResults))
