class ChangeCompleted < ActiveRecord::Migration
  def self.up
	change_column :tasks, :completed, :boolean, :default => false
	Task.all.each {|t| t.completed = (t.completed == true);t.save}
  end

  def self.down
  end
end
