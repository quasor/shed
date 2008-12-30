class CreateIntervals < ActiveRecord::Migration
  def self.up
    create_table :intervals do |t|
      t.datetime :start
      t.datetime :end
      t.integer :user_id
      t.integer :task_id
      t.decimal :hours

      t.timestamps
    end
  end

  def self.down
    drop_table :intervals
  end
end
