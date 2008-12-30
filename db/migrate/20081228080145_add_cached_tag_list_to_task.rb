class AddCachedTagListToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :cached_tag_list, :string
  end

  def self.down
    remove_column :tasks, :cached_tag_list
  end
end
