class Task < ActiveRecord::Base
  acts_as_nested_set
  acts_as_taggable_on :tags
  
  #validates_presence_of :user
  belongs_to :user
  include NestedSetList
  DEFAULT_VELOCITIIES = [0.72, 0.75, 0.81, 0.88, 1.8, 0.92, 0.94, 1.01, 1.21, 0.68]
  def estimate
    if low.blank? && high.blank?
      0
    elsif !low.blank?
      low.to_f
    elsif !low.blank? and !high.blank?
     low + ((high-low) * 0.5 ) 
    else
      0
    end
  end
  def monte_estimate()
    velocities ||= DEFAULT_VELOCITIIES 
    velocity = velocities[rand(velocities.size)]
    e = estimate / velocity
    # puts "Choosing estimate #{estimate }/ velocity #{velocity} = #{e}"
    e
  end
  def deleteable?
    children.nil? || children.size == 0
  end
end


