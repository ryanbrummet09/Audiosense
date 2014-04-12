acbound = 7; %21 combinations
lcbound = 5; %10
tfbound = 4; %6
vcbound = 3; %3
tlbound = 3; %3
nlbound = 4; %6
rsbound = 3; %3
cpbound = 2; %1
nzbound = 4; %6
bounds = [acbound lcbound tfbound vcbound tlbound nlbound rsbound cpbound nzbound];
testingSetIndex = 1;
testingSet = zeros(1,9);


for level = 1 : 4
    disp(level);
    if level == 1
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                testingSet(testingSetIndex,1) = (10*k1) + j1;
                testingSetIndex = testingSetIndex + 1;
            end
        end
    elseif level == 2
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            testingSet(testingSetIndex,1) = (10*k1) + j1;
                            testingSet(testingSetIndex,2) = (10*k2) + j2;
                            testingSetIndex = testingSetIndex + 1;
                        end
                    end
                end
            end 
        end
    elseif level == 3
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        testingSet(testingSetIndex,1) = (10*k1) + j1;
                                        testingSet(testingSetIndex,2) = (10*k2) + j2;
                                        testingSet(testingSetIndex,3) = (10*k3) + j3;
                                        testingSetIndex = testingSetIndex + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif level == 4
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                    testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                    testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                    testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                    testingSetIndex = testingSetIndex + 1; 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif level == 5
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    for k5 = 1 : 9
                                                        if(k5 ~= k4) && (k5 ~= k3) && (k5 ~= k2) && (k5 ~= k1)
                                                            for j5 = 1 : bounds(k5)
                                                                testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                                testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                                testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                                testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                                testingSet(testingSetIndex,5) = (10*k5) + j5;
                                                                testingSetIndex = testingSetIndex + 1;  
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif level == 6
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    for k5 = 1 : 9
                                                        if(k5 ~= k4) && (k5 ~= k3) && (k5 ~= k2) && (k5 ~= k1)
                                                            for j5 = 1 : bounds(k5)
                                                                for k6 = 1 : 9
                                                                    if(k6 ~= k5) && (k6 ~= k4) && (k6 ~= k3) && (k6 ~= k2) && (k6 ~= k1)
                                                                        for j6 = 1 : bounds(k6)
                                                                            testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                                            testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                                            testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                                            testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                                            testingSet(testingSetIndex,5) = (10*k5) + j5;
                                                                            testingSet(testingSetIndex,6) = (10*k6) + j6;
                                                                            testingSetIndex = testingSetIndex + 1;   
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif level == 7
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    for k5 = 1 : 9
                                                        if(k5 ~= k4) && (k5 ~= k3) && (k5 ~= k2) && (k5 ~= k1)
                                                            for j5 = 1 : bounds(k5)
                                                                for k6 = 1 : 9
                                                                    if(k6 ~= k5) && (k6 ~= k4) && (k6 ~= k3) && (k6 ~= k2) && (k6 ~= k1)
                                                                        for j6 = 1 : bounds(k6)
                                                                            for k7 = 1 : 9
                                                                                if(k7 ~= k6) && (k7 ~= k5) && (k7 ~= k4) && (k7 ~= k3) && (k7 ~= k2) && (k7 ~= k1)
                                                                                    for j7 = 1 : bounds(k7)
                                                                                         testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                                                         testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                                                         testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                                                         testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                                                         testingSet(testingSetIndex,5) = (10*k5) + j5;
                                                                                         testingSet(testingSetIndex,6) = (10*k6) + j6;
                                                                                         testingSet(testingSetIndex,7) = (10*k7) + j7;
                                                                                         testingSetIndex = testingSetIndex + 1; 
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif level == 8
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    for k5 = 1 : 9
                                                        if(k5 ~= k4) && (k5 ~= k3) && (k5 ~= k2) && (k5 ~= k1)
                                                            for j5 = 1 : bounds(k5)
                                                                for k6 = 1 : 9
                                                                    if(k6 ~= k5) && (k6 ~= k4) && (k6 ~= k3) && (k6 ~= k2) && (k6 ~= k1)
                                                                        for j6 = 1 : bounds(k6)
                                                                            for k7 = 1 : 9
                                                                                if(k7 ~= k6) && (k7 ~= k5) && (k7 ~= k4) && (k7 ~= k3) && (k7 ~= k2) && (k7 ~= k1)
                                                                                    for j7 = 1 : bounds(k7)
                                                                                         for k8 = 1 : 9
                                                                                             if(k8 ~= k7) && (k8 ~= k6) && (k8 ~= k5) && (k8 ~= k4) && (k8 ~= k3) && (k8 ~= k2) && (k8 ~= k1)
                                                                                                 for j8 = 1 : bounds(k8)
                                                                                                     testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                                                                     testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                                                                     testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                                                                     testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                                                                     testingSet(testingSetIndex,5) = (10*k5) + j5;
                                                                                                     testingSet(testingSetIndex,6) = (10*k6) + j6;
                                                                                                     testingSet(testingSetIndex,7) = (10*k7) + j7;
                                                                                                     testingSet(testingSetIndex,8) = (10*k8) + j8;
                                                                                                     testingSetIndex = testingSetIndex + 1;  
                                                                                                 end
                                                                                             end
                                                                                         end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for k1 = 1 : 9
            for j1 = 1 : bounds(k1)
                for k2 = 1 : 9
                    if k2 ~= k1
                        for j2 = 1 : bounds(k2)
                            for k3 = 1 : 9
                                if (k3 ~= k2) && (k3 ~= k1)
                                    for j3 = 1 : bounds(k3)
                                        for k4 = 1 : 9
                                            if (k4 ~= k3) && (k4 ~= k2) && (k4 ~= k1)
                                                for j4 = 1 : bounds(k4)
                                                    for k5 = 1 : 9
                                                        if(k5 ~= k4) && (k5 ~= k3) && (k5 ~= k2) && (k5 ~= k1)
                                                            for j5 = 1 : bounds(k5)
                                                                for k6 = 1 : 9
                                                                    if(k6 ~= k5) && (k6 ~= k4) && (k6 ~= k3) && (k6 ~= k2) && (k6 ~= k1)
                                                                        for j6 = 1 : bounds(k6)
                                                                            for k7 = 1 : 9
                                                                                if(k7 ~= k6) && (k7 ~= k5) && (k7 ~= k4) && (k7 ~= k3) && (k7 ~= k2) && (k7 ~= k1)
                                                                                    for j7 = 1 : bounds(k7)
                                                                                         for k8 = 1 : 9
                                                                                             if(k8 ~= k7) && (k8 ~= k6) && (k8 ~= k5) && (k8 ~= k4) && (k8 ~= k3) && (k8 ~= k2) && (k8 ~= k1)
                                                                                                 for j8 = 1 : bounds(k8)
                                                                                                     for k9 = 1 : 9
                                                                                                         if(k9 ~= k8) && (k9 ~= k7) && (k9 ~= k6) && (k9 ~= k5) && (k9 ~= k4) && (k9 ~= k3) && (k9 ~= k2) && (k9 ~= k1)
                                                                                                             for j9 = 1 : bounds(k9)
                                                                                                                 testingSet(testingSetIndex,1) = (10*k1) + j1;
                                                                                                                 testingSet(testingSetIndex,2) = (10*k2) + j2;
                                                                                                                 testingSet(testingSetIndex,3) = (10*k3) + j3;
                                                                                                                 testingSet(testingSetIndex,4) = (10*k4) + j4;
                                                                                                                 testingSet(testingSetIndex,5) = (10*k5) + j5;
                                                                                                                 testingSet(testingSetIndex,6) = (10*k6) + j6;
                                                                                                                 testingSet(testingSetIndex,7) = (10*k7) + j7;
                                                                                                                 testingSet(testingSetIndex,8) = (10*k8) + j8;
                                                                                                                 testingSet(testingSetIndex,9) = (10*k9) + j9;
                                                                                                                 testingSetIndex = testingSetIndex + 1;  
                                                                                                             end
                                                                                                         end
                                                                                                     end
                                                                                                 end
                                                                                             end
                                                                                         end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
size(testingSet)