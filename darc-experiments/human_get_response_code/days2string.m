function delayString = days2string(delay)

assert(isscalar(delay),'d should be a scalar')

% Durations (in days)
YEAR = 365;
MONTH = 30;
DAY = 1;
HOUR = 1/24;
MIN = 1/(24*60);

is_immediate    = @(t) t==0;
is_years        = @(t) rem(t,YEAR)==0;
is_months       = @(t) rem(t,MONTH)==0;
is_days         = @(t) rem(t,DAY)==0;
is_hours        = @(t) rem(t,HOUR)==0;

if is_immediate(delay)
	delayString = 'now';
    
elseif is_years(delay)
	delayString = sprintf('%d years', delay./YEAR );
    
elseif is_months(delay)
	delayString = sprintf('%d months', delay./MONTH );
    
elseif rem(delay,1)==0
	delayString = sprintf('%d days', delay./DAY );
    
elseif rem(delay,1/24)==0
	delayString = sprintf('%.0f hours', delay./HOUR );
    
elseif rem(delay,1/(24*60))==0
    delayString = sprintf('%.0f minutes', delay./MIN );
    
else
    error('Duration provided not a whole number of mins, hours, days, months, or years.')
end
