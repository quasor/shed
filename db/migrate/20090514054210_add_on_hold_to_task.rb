class AddOnHoldToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :on_hold, :boolean, :default => false
  end

  def self.down
    remove_column :tasks, :on_hold
  end
end
