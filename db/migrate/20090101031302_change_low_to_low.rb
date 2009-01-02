class ChangeLowToLow < ActiveRecord::Migration
  def self.up
    change_column :tasks, :low, :float, :default => 0.0
    change_column :tasks, :high, :float, :default => 0.0
    change_column :users, :efficiency, :float, :default => 0.0
    change_column :projections, :confidence, :float, :default => 0.0
  end

  def self.down
  end
end
