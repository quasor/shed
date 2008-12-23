class Task < ActiveRecord::Base
  acts_as_nested_set
  validates_presence_of :user
  belongs_to :user
  include NestedSetList
  DEFAULT_VELOCITIIES = [0.72, 0.75, 0.81, 0.88, 0.90, 0.92, 0.94, 1.01, 1.11, 1.68]
  def estimate
    if low && high
     low + ((high-low) * 0.5)
    else
      0
    end
  end
  def monte_estimate()
    velocities ||= DEFAULT_VELOCITIIES 
    velocity = velocities[rand(velocities.size)]
    e = estimate / velocity
    puts "Choosing estimate #{estimate }/ velocity #{velocity} = #{e}"
    e
  end
end


