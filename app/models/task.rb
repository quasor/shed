require 'nested_set_list'
class Task < ActiveRecord::Base
  acts_as_nested_set
  acts_as_taggable_on :tags
  include NestedSetList

  belongs_to :user
  has_many :intervals, :dependent => :destroy
  has_many :projections, :dependent => :destroy
  before_save {|r| r.low = 0 if r.low.blank?}
  #validates_presence_of :low
  validates_presence_of :title
  #validates_presence_of :user
  
  DEFAULT_VELOCITIIES = [0.72, 0.75, 0.81, 0.88, 1.8, 0.92, 0.94, 1.01, 1.21, 0.68]
  def estimate
    if !low.blank? and !high.blank?
      ((low + 4*(low + ((high-low) * 0.66 )) + high)/6.0).round(2)
    elsif !low.blank?
      low.to_f
    elsif low.blank? && high.blank?
      0
    end
  end

  def monte_estimate()
    velocities ||= DEFAULT_VELOCITIIES 
    velocity = velocities[rand(velocities.size)]
    e = estimate / velocity
    #puts "Choosing estimate #{estimate }/ velocity #{velocity} = #{e}"
    e
  end
  def deleteable?
    children.nil? || children.size == 0
  end
  
  # A leaf folder does not have any children. Return true if no
  # children exist for this folder.
  # This method does not require a database query.
  def leaf?
    self.all_children_count == 0
  end

  # Return true if this folder has no contents - either folders
  # or bookmarks.
  def empty?
    self.leaf?
  end

  # In the statement:
  #   @folder.ancestor_of(@other_folder)
  # The result is true if @other_folder is within the sub-tree of
  # @folder.
  # The result is false if @other_folder is outside @folder's sub-tree or if
  # @folder == @other_folder.
  # This method does not require a database query.
  def ancestor_of?(descendant)
    self.lft < descendant.lft && self.rgt > descendant.rgt
  end

  # In the statement:
  #   @folder.descendant_of(@other_folder)
  # The result is true if @other_folder is a direct ancestor of @folder.
  # Otherwise, false.
  # This method does not require a database query.
  def descendant_of?(ancestor)
    self.lft > ancestor.lft && self.rgt < ancestor.rgt
  end
  
  def status
    s = []
    s.push "completed" if self.completed?
    s.join ' '
  end
  
end


