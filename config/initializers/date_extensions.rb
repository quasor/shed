class Date
  def net_work_days_until(date1, date2=nil)
		flip = false
    if date2.nil?
      date2 = date1
      date1 = self
    end
		if (date2 < date1)
			flip = true
			date3 = date1
			date1 = date2
			date2 = date3
		end
    holidays = Holiday.all#find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
    dates = (date1.to_date .. date2.to_date).collect
    results = dates.collect {|d| d.wday == 0 || d.wday == 6 || holidays.include?(d)}
    n = results.find_all { |r| r == false }.size 
		n = n - 1 if n > 0
		n = n * -1 if flip 
		n 
  end
#  def work_day1(days)
#    if days.nil?
#      return nil
#    end
#    date1 = self
#    date2 = self + 365
#    holidays = Holiday.all#.find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
#    dates = (date1.to_date .. date2.to_date).collect
#    results = dates.collect {|d| [d.wday == 0 || d.wday == 6 || holidays.include?(d), d]}
#    results.find_all { |r| r[0] == false }[days.to_i][1] + days.modulo(1)
#  end
#  def work_day2(days)
#    if days.nil?
#      return nil
#    end
#    holidays = Holiday.all.collect(&:holiday)#.find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
#
#    date1 = self
#    date2 = self + days.to_i + holidays.size + (days.to_i / 7 * 2) + 1
#
#    dates = (date1.to_date .. date2.to_date).collect
#    results = dates.collect {|d| [d.wday == 0 || d.wday == 6 || holidays.include?(d), d]}
#    results.find_all { |r| r[0] == false }[days.to_i][1] + days.modulo(1)
#  end
end
class Date
  def work_day(days)
    if days.nil?
      return nil
    end
    #if days == 0 #|| (self.day_fraction + days < 1 && )
    #  return self # => + days.modulo(1)
    #end
    
    d = self
    c = self
    
    holidays = Rails.cache.fetch("Holiday.all.holiday") do
      Holiday.find(:all, :select => :holiday).collect(&:holiday)
    end
    wdays = [0,6]
    
    d = d + days.modulo(1)
    c = c + days.modulo(1)
    holiday_count = 0
    while (true)
      # if we've found a work day and enough time has passed return it
      unless d.wday == 0 || d.wday == 6 || holidays.include?(d)
        # unless it's a holiday or a weekend test to see if we're done
        if d - c - holiday_count >= days.div(1)
          break 
        end
      else
        holiday_count = holiday_count + 1
      end
      d = d + 1
    end
    if d.wday == 1 and d.day_fraction == 0 and (d - 2 > self)
      d - 2 #back track the weekend
    else
      d
    end
  end

end

def variance(population)
  n = 0
  mean = 0.0
  s = 0.0
  population.each { |x|
    n = n + 1
    delta = x - mean
    mean = mean + (delta / n)
    s = s + delta * (x - mean)
  }
  # if you want to calculate std deviation
  # of a sample change this to "s / (n-1)"
  return s / n
end

# calculate the standard deviation of a population
# accepts: an array, the population
# returns: the standard deviation
def standard_deviation(population)
  Math.sqrt(variance(population))
end

WORKING_HOURS_PER_DAY = 8.0

def format_seconds_as_working_days_hours(seconds)
	# round up to the minute
	# format the rest as 6:30 (6hours 30minutes)
	seconds = seconds.div(60) * 60
	days, seconds = seconds.divmod(WORKING_HOURS_PER_DAY.hours)
	hours, seconds  = seconds.divmod(1.hour)
	minutes,seconds = seconds.divmod(1.minute)
	days = days > 0 ? "#{days.to_i}d" : ""
	"#{days} #{hours}:#{"%02d" % minutes}".strip
end


def parse_as_days(string)
  unless string.nil?
		 # parse 2.5d as 2 days 4 hours
		 # parse 2.5h, 2.5 and 2:30 as 2 hours 30 minutes
     default_unit = string.scan("h").empty? ? 1 : WORKING_HOURS_PER_DAY
     days = 0.0
     string.downcase.scan(/(\d*)([\.|:])?(\d*)\s?([h|d|m]?)/).each do |part|  
		  major, sep, minor, unit = part
      n_unit = case unit
        when "h" : WORKING_HOURS_PER_DAY
        when "d" : 1
				when "m" : WORKING_HOURS_PER_DAY * 60.0
        else default_unit
      end
			f_unit = 10
			if sep == ":"
				n_unit = WORKING_HOURS_PER_DAY
				f_unit = 60
			end
     	days = days + (major.to_f / n_unit) + (minor.to_f / f_unit / n_unit)
   	end 
    days
  end
end