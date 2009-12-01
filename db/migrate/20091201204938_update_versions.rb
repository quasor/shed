class UpdateVersions < ActiveRecord::Migration
  def self.up
    add_column :task_versions, :start_in_days, :float, :default => 0.0
    add_column :task_versions, :end_in_days, :float, :default => 0.0
  end

  def self.down
    remove_column :task_versions, :start_in_days
    remove_column :task_versions, :end_in_days
  end
end
