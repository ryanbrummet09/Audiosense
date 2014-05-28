function unix = getUnixTime(years, months, days, hours, mins, secs)
    yearsPast = years - 1970;
    currentYear = 1970;
    leapDays = 0;
    while(yearsPast ~= 0)
        currentYear = currentYear + 1;
        if rem(currentYear, 4) == 0
            leapDays = leapDays + 1; 
        end
        yearsPast = yearsPast - 1;
    end
    yearsPast = years - 1970;
    if months < 3
        leapDays = leapDays - 1; 
    end
    totalDaysElapsed = leapDays;
    feb = 31;
    mar = 59;
    apr = 90;
    may = 120;
    jun = 151;
    jul = 181;
    aug = 212;
    sep = 243;
    oct = 273;
    nov = 304;
dec = 334;
    if months == 1
        totalDaysElapsed = totalDaysElapsed + days;
    elseif months == 2
        totalDaysElapsed = totalDaysElapsed + feb + days;
    elseif months == 3
        totalDaysElapsed = totalDaysElapsed + mar + days;
    elseif months == 4
        totalDaysElapsed = totalDaysElapsed + apr + days;
    elseif months == 5
        totalDaysElapsed = totalDaysElapsed + may + days;
    elseif months == 6
        totalDaysElapsed = totalDaysElapsed + jun + days;
    elseif months == 7
        totalDaysElapsed = totalDaysElapsed + jul + days;
    elseif months == 8
        totalDaysElapsed = totalDaysElapsed + aug + days;
    elseif months ==9
        totalDaysElapsed = totalDaysElapsed + sep + days;
    elseif months == 10
        totalDaysElapsed = totalDaysElapsed + oct + days;
    elseif months == 11
        totalDaysElapsed = totalDaysElapsed + nov + days;
    else
        totalDaysElapsed = totalDaysElapsed + dec + days;
    end
    
    unix = ((yearsPast * 31536000) + (totalDaysElapsed * 86400) + (hours * 3600) + (mins * 60) + secs + 21600);
end