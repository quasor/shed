class AddTeamToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :team_id, :integer
    User.reset_column_information
    User.all.each do |user|
      user.team_id = Task.root.id
      user.save
    end
  end

  def self.down
    remove_column :users, :team_id
  end
end
