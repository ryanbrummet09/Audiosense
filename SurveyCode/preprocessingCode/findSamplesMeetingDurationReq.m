%Ryan Brummet
%University of Iowa

function [ dataTable ] = findSamplesMeetingDurationReq( dataTable, ...
    threshold)
    %dataTable: table containing patient data

    %threshold: a number on the interval (0,1] such that for all data
    %           samples, duration must be on the interval 
    %           [avgDuration*threshold, avgDuration + avgDuration*threshold]

    startTimes = char(dataTable.starttime);
    endTimes = char(dataTable.endtime);
    unixStartTime = getUnixTime(str2num(startTimes(:,1:4)),str2num(startTimes(:,6:7)), ...
        str2num(startTimes(:,9:10)),str2num(startTimes(:,12:13)),str2num(startTimes(:,15:16)), ...
        str2num(startTimes(:,18:19)));
%     unixEndTime = getUnixTime(str2num(endTimes(:,1:4)),str2num(endTimes(:,6:7)), ...
%         str2num(endTimes(:,9:10)), str2num(endTimes(:,12:13)),str2num(endTimes(:,15:16)), ...
%         str2num(endTimes(:,18:19)));
%     durations = unixEndTime - unixStartTime;
%     subjectIDs = unique(dataTable.patient);
%     for k = 1 : size(subjectIDs,1)
%         durationMeans(subjectIDs(k),1) = mean(durations((dataTable.patient == subjectIDs(k)),1));
%     end
%     indexes = (durations >= durationMeans(dataTable.patient)*threshold & ...
%         durations <= durationMeans(dataTable.patient) + ...
%         durationMeans(dataTable.patient)*threshold);
%     dataTable = dataTable(indexes,:);
%     dataTable.timestamp = unixStartTime(indexes);
    dataTable.timestamp = unixStartTime;
end

