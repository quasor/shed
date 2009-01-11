class Interval < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  validates_presence_of :user_id
  validates_presence_of :task_id
  named_scope :active, :conditions => {:end => nil}
  def to_f
    self.end - self.start unless self.end.nil? || self.start.nil?
  end
  alias :to_seconds :to_f
  def duration
    unless self.end.nil? || self.start.nil?
      Duration.new(self.start, self.end) 
    end
  end
end
