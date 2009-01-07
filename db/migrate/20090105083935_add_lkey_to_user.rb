class AddLkeyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :loginkey, :string
    User.reset_column_information
    User.all.each {|u| u.update_login_key}
  end

  def self.down
    remove_column :users, :loginkey
  end
end
