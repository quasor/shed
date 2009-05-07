class OrderTasks < ActiveRecord::Migration
  def self.up
		tasks = Task.root.descendants
		p = 1
		for task in tasks do
			task.insert_at p
			p = p + 1
		end
  end

  def self.down
  end
end
