class AddOffsetsToStartAndEnd < ActiveRecord::Migration
  def self.up
    add_column :tasks, :start_in_days, :float, :default => 0.0
    add_column :tasks, :end_in_days, :float, :default => 0.0
  end

  def self.down
    remove_column :tasks, :start_in_days
    remove_column :tasks, :end_in_days
  end
end
