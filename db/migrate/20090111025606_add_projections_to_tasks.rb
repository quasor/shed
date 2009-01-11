class AddProjectionsToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :best_start, :date
    add_column :tasks, :worst_start, :date
    add_column :tasks, :best_end, :date
    add_column :tasks, :worst_end, :date
  end

  def self.down
    remove_column :tasks, :best_start
    remove_column :tasks, :best_end
    remove_column :tasks, :worst_start
    remove_column :tasks, :worst_end
  end
end
