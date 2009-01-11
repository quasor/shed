class Projection < ActiveRecord::Base
  belongs_to :task
  belongs_to :simulation
  validates_presence_of :task_id
  named_scope :by_task, lambda { |t| {:conditions => {:task_id => t}} }
  named_scope :rollup, :conditions => {:user_id => nil}
  named_scope :rollup_by_user, lambda { |user_id| { :conditions => {:user_id => user_id} } }
  named_scope :simulation, lambda { |sim_id| { :conditions => {:simulation_id => sim_id} } }
  named_scope :confidence, lambda { |c| { :conditions => {:confidence => c} } }
  before_save do |r| 
    if r.end == task.start.to_date
      task_end = task_end + 1
    end
  end
end
