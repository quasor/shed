class Project < Task
  validates_uniqueness_of :title
end
