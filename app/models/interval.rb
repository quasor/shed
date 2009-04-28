class Interval < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  validates_presence_of :user_id
  validates_presence_of :task_id
  named_scope :active, :conditions => {:end => nil}
  def to_f
		unless self.end.nil? || self.start.nil?
    	self.end - self.start 
		else
			0.0
		end
  end
  alias :to_seconds :to_f
  def duration
    unless self.end.nil? || self.start.nil?
      Duration.new(self.start, self.end) 
    end
  end
end

def string_to_days(string)
  unless string.nil?
      # look for h in e.g. 1-2h or 1h-2 = 1h-2h
      # 1-2 = 1d - 2d
      default_unit = self.estimate.scan("h").empty? ? 1 : WORKING_HOURS_PER_DAY
      days = 0.0
      string.downcase.scan(/(\d*\.*\d*)\s?([h|d]?)/).each do |part|  
      n_unit = case part[1]
        when "h" : WORKING_HOURS_PER_DAY
        when "d" : 1
        else default_unit
      end
      days = days + (part[0].to_f / n_unit)
    end 
    days
  end
end