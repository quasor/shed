class AddUserIdToProjection < ActiveRecord::Migration
  def self.up
    add_column :projections, :user_id, :integer
    add_column :projections, :simulation_id, :integer
  end

  def self.down
    remove_column :projections, :simulation_id
    remove_column :projections, :user_id
  end
end
