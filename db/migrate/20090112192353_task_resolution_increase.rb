class TaskResolutionIncrease < ActiveRecord::Migration
  def self.up
	change_column :tasks, :start, :datetime
	change_column :tasks, :end, :datetime
  end

  def self.down
  end
end
