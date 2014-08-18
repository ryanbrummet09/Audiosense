index = 1;
for k = 1 : size(dummyData,2)
    for j = k + 1 : size(dummyData,2)
        disp(isequal(table2array(dummyData(:,k)),table2array(dummyData(:,j))))
        if isequal(table2array(dummyData(:,k)),table2array(dummyData(:,j)))
             duplicates(index,1) = char(dummyData(:,k).Properties.VariableNames);
             duplicates(index,2) = char(dummyData(:,j).Properties.VariableNames);
             index = index + 1;
        end
    end 
end