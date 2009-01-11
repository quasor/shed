class ChangeConfidence < ActiveRecord::Migration
  def self.up
    change_column :projections, :confidence, :integer
  end

  def self.down
  end
end
