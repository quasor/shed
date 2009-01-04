class Project < Task
#  include NestedSetList
  validates_uniqueness_of :title
end
