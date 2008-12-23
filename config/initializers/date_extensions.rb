class Date
  def net_work_days_until(date1, date2=nil)
    if date2.nil?
      date2 = date1
      date1 = self
    end
    holidays = Holiday.find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
    dates = (date1.to_date .. date2.to_date).collect
    results = dates.collect {|d| d.wday == 0 || d.wday == 6 || holidays.include?(d)}
    results.find_all { |r| r == false }.size
  end
  def work_day(days)
    if days.nil?
      return nil
    end
    date1 = self
    date2 = self + 365
    holidays = Holiday.find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
    dates = (date1.to_date .. date2.to_date).collect
    results = dates.collect {|d| [d.wday == 0 || d.wday == 6 || holidays.include?(d), d]}
    results.find_all { |r| r[0] == false }[days.to_i][1] + days.modulo(1)
  end
end
