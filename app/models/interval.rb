class Interval < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  validates_presence_of :user
  validates_presence_of :task
end
