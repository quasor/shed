require 'nested_set_list'
class Task < ActiveRecord::Base
  acts_as_nested_set
  acts_as_taggable_on :tags
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

  WORKING_HOURS_PER_DAY = 8
  
  def string_to_days(string)
    unless string.nil?
        # look for h in e.g. 1-2h or 1h-2 = 1h-2h
        # 1-2 = 1d - 2d
        default_unit = self.estimate.scan("h").empty? ? 1 : WORKING_HOURS_PER_DAY
        days = 0.0
        string.downcase.scan(/(\d*\.*\d)\s?([h|d]?)/).each do |part|
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
    velocities ||= DEFAULT_VELOCITIIES 
    velocity = velocities[rand(velocities.size)]
    e = estimate_days / velocity
    #puts "Choosing estimate #{estimate }/ velocity #{velocity} = #{e}"
    e
  end
  def deleteable?
    children.nil? || children.size == 0
  end
  
  # A leaf folder does not have any children. Return true if no
  # children exist for this folder.
  # This method does not require a database query.
  def leaf?
    self.all_children_count == 0
  end

  # Return true if this folder has no contents - either folders
  # or bookmarks.
  def empty?
    self.leaf?
  end

  # In the statement:
  #   @folder.ancestor_of(@other_folder)
  # The result is true if @other_folder is within the sub-tree of
  # @folder.
  # The result is false if @other_folder is outside @folder's sub-tree or if
  # @folder == @other_folder.
  # This method does not require a database query.
  def ancestor_of?(descendant)
    self.lft < descendant.lft && self.rgt > descendant.rgt
  end

  # In the statement:
  #   @folder.descendant_of(@other_folder)
  # The result is true if @other_folder is a direct ancestor of @folder.
  # Otherwise, false.
  # This method does not require a database query.
  def descendant_of?(ancestor)
    self.lft > ancestor.lft && self.rgt < ancestor.rgt
  end
  
  def status
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


