class Projection < ActiveRecord::Base
  belongs_to :task
  validates_presence_of :task_id
  named_scope :rollup, :conditions => {:user_id => nil}
  named_scope :rollup_by_user, lambda { |user_id| { :conditions => {:user_id => user_id} } }
  
end
