class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.date :holiday

      t.timestamps
    end
  end

  def self.down
    drop_table :holidays
  end
end
