class Release < Task
  validates_uniqueness_of :title
end
