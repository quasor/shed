class Release < Task
  validates_uniqueness_of :title
  def self.status
    "completed" if self.completed?
  end
end
