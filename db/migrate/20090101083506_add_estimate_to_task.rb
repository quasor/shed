class AddEstimateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :estimate, :string
    # clean up the mess
    Task.delete_all
    Interval.delete_all
    Projection.delete_all
  end

  def self.down
    remove_column :tasks, :estimate
  end
end
