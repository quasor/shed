
class Holiday < ActiveRecord::Base
  validates_uniqueness_of :holiday

  def self.between(date1, date2=nil)
    if date2.nil?
      date2 = date1
      date1 = self
    end
    Holiday.find(:all, :conditions => {:holiday => date1..date2 }).collect(&:holiday)
  end

end
