%Ryan Brummet
%University of Iowa

function [ unixTime ] = getUnixTime(years, months, days, hours, mins, secs)
    yearsPast = years - 1970;
    leapDays = floor((years - 1972) / 4) + 1 + (months < 3);
    cumDaysMonth = [0 31 59 90 120 151 181 212 243 273 304 334];
    totalDaysElapsed = leapDays + cumDaysMonth(months)' + days - 1;
    unixTime = (yearsPast * 31536000) + (totalDaysElapsed * 86400) + ...
        (hours * 3600) + (mins * 60) + secs;
end