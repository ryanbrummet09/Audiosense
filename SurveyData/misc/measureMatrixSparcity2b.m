clc;
clear;
close;
fid = fopen('newData.csv');
fgetl(fid);
charArray = fgetl(fid);
index = 1;
%columns in the extractedData matrx have the form
%Patient, listening, userInit, ac, lc, tf, vc, tl, nl, rs, cp, nz, condition, sp, le, ld, ld2, lcl,
%ap, qol, im, st
%We do not consider data samples where a patient was not wearing a hearing
%aid
while(ischar(charArray))
    clearvars temp;
    charArray = strsplit(charArray, ',');
    if str2double(charArray(1,28)) == 1
        temp = cell2mat(charArray(1,1));
        temp = temp(4:5);
        extractedData(index,1) = str2double(temp);
        extractedData(index,2) = str2double(charArray(1,8));
        extractedData(index,3) = str2double(charArray(1,34));
        extractedData(index,4) = str2double(charArray(1,13));
        extractedData(index,5) = str2double(charArray(1,15));
        extractedData(index,6) = str2double(charArray(1,16));
        extractedData(index,7) = str2double(charArray(1,17));
        extractedData(index,8) = str2double(charArray(1,18));
        extractedData(index,9) = str2double(charArray(1,20));
        extractedData(index,10) = str2double(charArray(1,21));
        extractedData(index,11) = str2double(charArray(1,22));
        extractedData(index,12) = str2double(charArray(1,19));
        clearvars temp;
        extractedData(index,13) = str2double(charArray(1,2));
        
        if str2double(charArray(1,23)) ~= 50
            extractedData(index,14) = str2double(charArray(1,23));
        else
            extractedData(index,14) = NaN;
        end
        if str2double(charArray(1,24)) ~= 50
            extractedData(index,15) = str2double(charArray(1,24));
        else
            extractedData(index,15) = NaN;
        end
        if str2double(charArray(1,25)) ~= 50
            extractedData(index,16) = str2double(charArray(1,25));
        else
            extractedData(index,16) = NaN;
        end
        if str2double(charArray(1,26)) ~= 50
            extractedData(index,17) = str2double(charArray(1,26));
        else
            extractedData(index,17) = NaN;
        end
        if str2double(charArray(1,27)) ~= 50
            extractedData(index,18) = str2double(charArray(1,27));
        else
            extractedData(index,18) = NaN;
        end
        if str2double(charArray(1,31)) ~= 50
            extractedData(index,19) = str2double(charArray(1,31));
        else
            extractedData(index,19) = NaN;
        end
        if str2double(charArray(1,32)) ~= 50
            extractedData(index,20) = str2double(charArray(1,32));
        else
            extractedData(index,20) = NaN;
        end
        if str2double(charArray(1,33)) ~= 50
            extractedData(index,21) = str2double(charArray(1,33));
        else
            extractedData(index,21) = NaN;
        end
        if str2double(charArray(1,30)) ~= 50
            extractedData(index,22) = str2double(charArray(1,30));
        else
            extractedData(index,22) = NaN;
        end
        %end
        for k = 1 : size(charArray,2)
           rawData(index,k) = charArray(1,k); 
        end
        index = index + 1;
    end
    charArray = fgetl(fid);
end
%construsts array that contains every possible contex
%a contex has the form cid, ac, lc, tf, vc, tl, nl, rs, cp, nz, condition
%where cid is a unique number assigned to each contex and only conditions
%that have been recorded are considered part of the contex.  There maybe
%other possible conditions that do not appear in our data, but since we
%don't know how many possible conditions there are we are only considering
%those that we know exist.  We are also assuming that a condition can be no
%more that 2 digits long.

%Also builds a two column matrix that matches cid against quantity
%matrix is of the form cid, quantity
index = 1;
conditions = unique(extractedData(:,13));
for ac = 1 : 7
   if ac < 6
       for nz = 1 : 4
          if nz ~= 1
              for lc = 1 : 5
                  if lc < 3
                      for tf = 1 : 4
                         for vc = 1 : 3
                            for tl = 1 : 3
                               for nl = 1 : 4
                                   for cnd = 1 : size(conditions,1)
                                      if ac == 5
                                          tlSub = 0; 
                                      else
                                          tlSub = tl;
                                      end
                                      %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (nl * 100000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                      %contexts(index,2) = ac;
                                      %contexts(index,3) = lc;
                                      %contexts(index,4) = tf;
                                      %contexts(index,5) = vc;
                                      %contexts(index,6) = tl;
                                      %contexts(index,7) = nl;
                                      %contexts(index,8) = 0;
                                      %contexts(index,9) = 0;
                                      %contexts(index,10) = nz;
                                      %contexts(index,11) = conditions(cnd,1);
                                      contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (nl * 100000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                      contextQuantity(index,2) = 0;
                                      index = index + 1;
                                   end
                               end
                               if ac == 5
                                   break; 
                               end
                            end
                         end
                      end
                  else
                      for tf = 1 : 4
                         for vc = 1 : 3
                            for tl = 1 : 3
                               for nl = 1 : 4
                                   for rs = 1 : 3
                                      for cp = 1 : 2
                                         for cnd = 1 : size(conditions,1)
                                            if ac == 5
                                                tlSub = 0; 
                                            else
                                                tlSub = tl;
                                            end
                                            %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (nl * 100000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                            %contexts(index,2) = ac;
                                            %contexts(index,3) = lc;
                                            %contexts(index,4) = tf;
                                            %contexts(index,5) = vc;
                                            %contexts(index,6) = tl;
                                            %contexts(index,7) = nl;
                                            %contexts(index,8) = rs;
                                            %contexts(index,9) = cp;
                                            %contexts(index,10) = nz;
                                            %contexts(index,11) = conditions(cnd,1);
                                            contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (nl * 100000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                            contextQuantity(index,2) = 0;
                                            index = index + 1;
                                         end
                                      end
                                   end
                               end
                               if ac == 5
                                   break; 
                               end
                            end
                         end
                      end
                  end
              end
          else
              for lc = 1 : 5
                 if lc < 3
                     for tf = 1 : 4
                         for vc = 1 : 3
                            for tl = 1 : 3
                                for cnd = 1 : size(conditions,1)
                                    if ac == 5
                                        tlSub = 0; 
                                    else
                                        tlSub = tl;
                                    end
                                    %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                    %contexts(index,2) = ac;
                                    %contexts(index,3) = lc;
                                    %contexts(index,4) = tf;
                                    %contexts(index,5) = vc;
                                    %contexts(index,6) = tl;
                                    %contexts(index,7) = 0;
                                    %contexts(index,8) = 0;
                                    %contexts(index,9) = 0;
                                    %contexts(index,10) = nz;
                                    %contexts(index,11) = conditions(cnd,1);
                                    contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                    contextQuantity(index,2) = 0;
                                    index = index + 1;
                                end
                                if ac == 5
                                    break; 
                                end
                            end
                         end
                      end
                 else
                     for tf = 1 : 4
                         for vc = 1 : 3
                            for tl = 1 : 3
                                for rs = 1 : 3
                                    for cp = 1 : 2
                                        for cnd = 1 : size(conditions,1)
                                            if ac == 5
                                                tlSub = 0; 
                                            else
                                                tlSub = tl;
                                            end
                                            %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                            %contexts(index,2) = ac;
                                            %contexts(index,3) = lc;
                                            %contexts(index,4) = tf;
                                            %contexts(index,5) = vc;
                                            %contexts(index,6) = tl;
                                            %contexts(index,7) = 0;
                                            %contexts(index,8) = rs;
                                            %contexts(index,9) = cp;
                                            %contexts(index,10) = nz;
                                            %contexts(index,11) = conditions(cnd,1);
                                            contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (tlSub * 1000000) + (vc * 10000000) + (tf * 100000000) + (lc * 1000000000) + (ac * 10000000000);
                                            contextQuantity(index,2) = 0;
                                            index = index + 1;
                                        end
                                    end
                                end
                                if ac == 5
                                    break; 
                                end
                            end
                         end
                      end
                 end
              end
          end
       end
   else
       for nz = 1 : 4
          if nz ~= 1
             for lc = 1 : 5
                if lc < 3
                    for nl = 1 : 4
                       for cnd = 1 : size(conditions,1)
                           %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (nl * 100000) + (lc * 1000000000) + (ac * 10000000000);
                           %contexts(index,2) = ac;
                           %contexts(index,3) = lc;
                           %contexts(index,4) = 0;
                           %contexts(index,5) = 0;
                           %contexts(index,6) = 0;
                           %contexts(index,7) = nl;
                           %contexts(index,8) = 0;
                           %contexts(index,9) = 0;
                           %contexts(index,10) = nz;
                           %contexts(index,11) = conditions(cnd,1);
                           contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (nl * 100000) + (lc * 1000000000) + (ac * 10000000000);
                           contextQuantity(index,2) = 0;
                           index = index + 1;
                       end
                    end
                else
                    for nl = 1 : 4
                       for rs = 1 : 3
                          for cp = 1 : 2 
                             for cnd = 1 : size(conditions,1)
                                %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (nl * 100000) + (lc * 1000000000) + (ac * 10000000000);
                                %contexts(index,2) = ac;
                                %contexts(index,3) = lc;
                                %contexts(index,4) = 0;
                                %contexts(index,5) = 0;
                                %contexts(index,6) = 0;
                                %contexts(index,7) = nl;
                                %contexts(index,8) = rs;
                                %contexts(index,9) = cp;
                                %contexts(index,10) = nz;
                                %contexts(index,11) = conditions(cnd,1);
                                contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (nl * 100000) + (lc * 1000000000) + (ac * 10000000000);
                                contextQuantity(index,2) = 0;
                                index = index + 1; 
                             end
                          end
                       end
                    end
                end
             end
          else
              for lc = 1 : 5
                 if lc < 3
                     for cnd = 1 : size(conditions,1)
                        %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (lc * 1000000000) + (ac * 10000000000);
                        %contexts(index,2) = ac;
                        %contexts(index,3) = lc;
                        %contexts(index,4) = 0;
                        %contexts(index,5) = 0;
                        %contexts(index,6) = 0;
                        %contexts(index,7) = 0;
                        %contexts(index,8) = 0;
                        %contexts(index,9) = 0;
                        %contexts(index,10) = nz;
                        %contexts(index,11) = conditions(cnd,1);
                        contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (lc * 1000000000) + (ac * 10000000000);
                        contextQuantity(index,2) = 0;
                        index = index + 1; 
                     end
                 else
                     for rs = 1 : 3
                        for cp = 1 : 2
                           for cnd = 1 : size(conditions,1)
                              %contexts(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (lc * 1000000000) + (ac * 10000000000);
                              %contexts(index,2) = ac;
                              %contexts(index,3) = lc;
                              %contexts(index,4) = 0;
                              %contexts(index,5) = 0;
                              %contexts(index,6) = 0;
                              %contexts(index,7) = 0;
                              %contexts(index,8) = rs;
                              %contexts(index,9) = cp;
                              %contexts(index,10) = nz;
                              %contexts(index,11) = conditions(cnd,1);
                              contextQuantity(index,1) = conditions(cnd,1) + (nz * 100) + (cp * 1000) + (rs * 10000) + (lc * 1000000000) + (ac * 10000000000);
                              contextQuantity(index,2) = 0;
                              index = index + 1; 
                           end
                        end
                     end
                 end
              end
          end
       end
   end
end
contextIndexes = zeros([size(contextQuantity,1),1 + size(extractedData,1)]);
contextIndexes(:,1) = contextQuantity(:,1);
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
   temp = find(contextQuantity == temp);
   contextQuantity(temp,2) = contextQuantity(temp,2) + 1;
   contextIndexes(temp,k + 1) = k;
end
clearvars temp;
index = 1;
for k = 1 : size(contextIndexes,1)
    if contextQuantity(k,2) > 0 
        temp(index,:) = contextIndexes(k,:);
        index = index + 1;
    end
end
clearvars contextIndexes;
contextIndexes = temp;
clearvars temp;
[sortedContextQuantity, indices] = sort(contextQuantity(:,2),'descend');
index = 1;
for k = 1 : size(extractedData,1)
   for j = 14 : size(extractedData,2)
      if extractedData(k,j) == 100 || extractedData(k,j) == 0
         for i = 1 : size(extractedData,2)
            potentialBadData(index,i) = extractedData(k,i); 
         end
         index = index + 1;
         break;
      end
   end
end
semilogx(sortedContextQuantity);
