class RenameLowHighColumns < ActiveRecord::Migration
  def self.up
    rename_column :tasks, :low, :low_estimate_cache
    rename_column :tasks, :high, :high_estimate_cache
  end

  def self.down
    rename_column :tasks, :low_estimate_cache, :low
    rename_column :tasks, :high_estimate_cache, :high
  end
end
