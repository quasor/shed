class AddTaskIdxToInterval < ActiveRecord::Migration
  def self.up
		add_index :intervals, :task_id
  end

  def self.down
  end
end
