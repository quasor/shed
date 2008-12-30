class AddEndToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :end, :date
  end

  def self.down
    remove_column :tasks, :end
  end
end
