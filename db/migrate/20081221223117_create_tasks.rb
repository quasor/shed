class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title
      t.string :type
      t.text :description
      t.decimal :low
      t.decimal :high
      t.boolean :completed
      t.integer :user_id
      t.date :start

      # Acts as Better Nested Set:
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
         
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
