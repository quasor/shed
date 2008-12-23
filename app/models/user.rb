class User < ActiveRecord::Base
  has_many :tasks
  validates_uniqueness_of :login
  validates_presence_of :login
  before_save {|r| r.name = r.login if r.name.blank?}
end
