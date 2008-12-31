class Interval < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  validates_presence_of :user_id
  validates_presence_of :task_id
  named_scope :active, :conditions => {:end => nil}
end
