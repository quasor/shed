class AddIndexToProjections < ActiveRecord::Migration
  def self.up
		add_index :projections, :task_id
		add_index :tasks, :user_id
  end

  def self.down
  end
end
