#require 'nested_set_list'
class Task < ActiveRecord::Base
  acts_as_nested_set
#  acts_as_taggable_on :tags
  named_scope :by_user, lambda { |user_id| { :conditions => {:user_id => user_id} } }
  named_scope :active, :conditions => {:completed => false, :type => nil}
  named_scope :complete, :conditions => {:completed => true}
  include NestedSetList

  belongs_to :user
  has_many :intervals, :dependent => :destroy
  has_many :projections, :dependent => :destroy
  #validates_presence_of :low
  validates_presence_of :title
  #validates_presence_of :user
  
  DEFAULT_VELOCITIIES = [0.72, 0.75, 0.81, 0.88, 1.8, 0.92, 0.94, 1.01, 1.21, 0.68]
  def estimate_days
    if !low.blank? and !high.blank?
      ((low + 4*(low + ((high-low) * 0.66 )) + high)/6.0).round(2)
    elsif !low.blank?
     low.to_f
    elsif low.blank? && high.blank?
      0.0
    end
  end
  
  def estimate_duration
    Duration.new((self.estimate_days * 8.hours))
  end

	def touched_today?
		updated_at.to_date == Date.today
	end
  
  def velocity
    ed = self.estimate_days
    if self.completed? && ed > 0 && !self.intervals.empty?
      act = self.intervals.collect {|i| i.to_seconds}.sum
      est = ed * 8.hours
      r = est / act
      (0.20 <= r && r <= 20 ) ? r : nil
    end
  end

	def duration_friendly
		d = duration
		s = ""
		s = s + "#{d.days}d " unless d.days == 0
		s = s + "#{d.hours}h #{d.minutes}m"
	end
	
	def duration
		Duration.new(self.intervals.find(:all, :conditions => {:end => Date.today..Date.today+1}).collect {|i| i.to_seconds}.sum)
	end
  
  def friendly_estimate
    ed = self.estimate_days
    if ed < 2
      Duration.new(ed * 8.hours)
    else
      ed
    end
  end

  WORKING_HOURS_PER_DAY = 8
  
  def task?
    self.type.nil?
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

  def low
    unless self.estimate.nil?
      l,h = self.estimate.split "-" 
      string_to_days(l)
    end
  end
  def high
    unless self.estimate.nil?
      l,h = self.estimate.split "-"
      string_to_days(h)      
    end
  end
  
  def due_date
    self.due || ( !self.parent.nil? && self.parent.due) || (!self.parent.parent.nil? && self.parent.parent.due)
  end

  def monte_estimate()
    velocities = Rails.cache.fetch("velocities_for_user_#{self.user_id}", :expires_in => 10.minutes) { 
      self.user.tasks.map(&:velocity).compact 
    }
    velocities = velocities + DEFAULT_VELOCITIIES + DEFAULT_VELOCITIIES unless velocities.size > 20
    #puts velocities
    velocity = velocities[rand(velocities.size)]
    e = estimate_days / velocity
    #puts "Choosing estimate #{estimate_days} / velocity #{velocity} = #{e}"
    e
  end
  def deleteable?
    leaf?
  end
  
  # A leaf folder does not have any children. Return true if no
  # children exist for this folder.
  # This method does not require a database query.

  # Return true if this folder has no contents - either folders
  # or bookmarks.
  
  def self.status
    "completed" if self.completed?
  end
    
  def formatted_estimate_part(part)
    days = "#{part.div(1)}d"
    hours = part.modulo(1) > 0 ? " #{part.modulo(1)*8}h" : ""
    (days + " " + hours).strip
  end

  def formatted_estimate
    low_str = formatted_estimate_part(self.low)
    high_str = formatted_estimate_part(self.high)
    unless high_str.blank?
      low_str + " - " + high_str
    else
      low_str
    end
  end
  
end


