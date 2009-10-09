class CreateTaskVersions < ActiveRecord::Migration
  def self.up
    #Task.reset_column_information
		#Task.create_versioned_table
  end

  def self.down
		#Task.drop_versioned_table
  end
end
