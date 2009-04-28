class User < ActiveRecord::Base
  require 'digest/sha1'
  has_many :tasks
  has_many :intervals
  validates_uniqueness_of :login
  validates_presence_of :login
  before_save {|r| r.name = r.login if r.name.blank?}
  has_many :active_intervals, :source => :intervals, :class_name => 'Interval', :conditions => {:end => nil}
  
  def active_interval
    i = active_intervals(true).first
    if !i.nil? and i.task.completed == true
      i.end = DateTime.now
      i.save!
      i = nil
    end
    i
  end
  def update_login_key
    s = Digest::SHA1.hexdigest('username' + self.login + rand(12345).to_s).to_s.reverse
    self.loginkey = s
    self.save
  end

  before_save {|r| r.loginkey = Digest::SHA1.hexdigest(r.login + rand(12345).to_s).to_s.reverse }
  before_create {|r| r.team_id = 1 } #Team.all.first.id }

  def current_task
    active_intervals.first && active_intervals.first.task
  end
end
