xml.instruct! :xml, :version=>"1.0" 

xml.tasks do
	for task in @tasks do
		xml.task do
			xml.release task.parent.parent.title
			xml.project task.parent.title
			xml.title task.title
			xml.tags task.tag_list
			xml.owner task.user.name
			xml.estimate_text task.estimate
			xml.estimate_days task.estimate_days
			xml.start_date	task.start.to_date
			xml.end_date	task.end.to_date
			xml.start_week task.start.to_date.cweek - Date.today.cweek + 1
			xml.end_week task.end.to_date.cweek - Date.today.cweek + 1
			xml.order task.position
		end if task.type.nil?
	end
end

