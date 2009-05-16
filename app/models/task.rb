#require 'nested_set_list'
#require 'acts_as_list'
class Task < ActiveRecord::Base
  acts_as_nested_set
  acts_as_taggable_on :tags
	
  named_scope :by_user, lambda { |user_id| { :conditions => {:user_id => user_id} } }
  named_scope :active, :conditions => {:completed => false, :type => nil}
  named_scope :complete, :conditions => {:completed => true}
	named_scope :upcoming, :conditions => ["due > ?", Date.today]
  include NestedSetList
  named_scope :incomplete, :conditions => {:completed => false}

  belongs_to :user
	acts_as_list# :scope => :user_id

  has_many :intervals, :dependent => :destroy
  has_many :projections, :dependent => :destroy
  #validates_presence_of :low
  validates_presence_of :title
  #validates_presence_of :user
  
  DEFAULT_VELOCITIIES = [0.72, 0.75, 0.81, 0.88, 1.8, 0.92, 0.94, 1.01, 1.21, 0.68]

	def touch
		self.updated_at = Time.now
		self.save!
	end

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
  def duration_days
		(self.end - self.start)/1.day
	end

  def start_in_days
		t = Time.now.to_date.to_time
		s = (self.start - t).to_f / 1.day
		s > 0 ? s : 0
	end

  def velocity
    ed = self.estimate_days
    if self.completed? && ed > 0 && !self.intervals.empty?
      act = self.intervals.collect {|i| i.to_seconds}.sum
      est = ed * WORKING_HOURS_PER_DAY.hours
      r = est / act
      (0.20 <= r && r <= 20 ) ? r : nil
    end
  end

	def time_spent_today
		seconds = self.intervals.find(:all, :conditions => {:end => Date.today..Date.today+1}).collect {|i| i.to_seconds}.sum
		format_seconds_as_working_days_hours(seconds)
	end

	def time_spent_friendly
		seconds = self.intervals.collect {|i| i.to_seconds}.sum
		format_seconds_as_working_days_hours(seconds)
	end

	
  def has_actuals?
		self.intervals.size > 0	
	end

  def friendly_estimate
    ed = self.estimate_days
    if ed < 2
      Duration.new(ed * WORKING_HOURS_PER_DAY.hours)
    else
      ed
    end
  end

	def indent_size
		case self.type
			when "Release" then 8
			when "Project" then 4
			else 0
		end
	end

	def type_string
		if self.type.nil?
			"Task"
		else
			self.type
		end
	end
  
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
    hours = part.modulo(1) > 0 ? " #{part.modulo(1)*WORKING_HOURS_PER_DAY}h" : ""
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
	
	def completed_without_actuals?
		self.completed? && !self.estimate.blank? && !self.has_actuals?
	end
  
end


