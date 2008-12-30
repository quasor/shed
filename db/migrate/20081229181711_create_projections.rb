class CreateProjections < ActiveRecord::Migration
  def self.up
    create_table :projections do |t|
      t.integer :task_id
      t.date :start
      t.date :end
      t.decimal :confidence

      t.timestamps
    end
  end

  def self.down
    drop_table :projections
  end
end
