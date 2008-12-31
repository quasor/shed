module TasksHelper
  def variance(population)
     n = 0
     mean = 0.0
     s = 0.0
     population.each { |x|
       n = n + 1
       delta = x - mean
       mean = mean + (delta / n)
       s = s + delta * (x - mean)
     }
     # if you want to calculate std deviation
     # of a sample change this to "s / (n-1)"
     return [s / n, s/(n-1)]
   end
    
   # calculate the standard deviation of a population
   # accepts: an array, the population
   # returns: the standard deviation
   def standard_deviation(population)
     Math.sqrt(variance(population)[0])
   end  

  def sim_end_dates(root)
    durationz = Rails.cache.fetch("durations_for_#{root.cache_key}") do 
      durations = []
      100.times do |i|
        user_end_dates = {}
        tasks_raw = root.all_children
        #duration = root.all_children.collect(&:monte_estimate).sum
        #durations.push duration
        
        tasks_raw.each do |task|
          unless task.user.nil? || task.completed? 
            user_end_dates[task.user.id] ||= Date.today.work_day(0)
            task.start = user_end_dates[task.user.id].work_day(0)
            user_end_dates[task.user.id] = user_end_dates[task.user.id].work_day(task.monte_estimate)
          else 
            task.start = Date.today
          end
        end
        
        durations.push(user_end_dates.values.max - Date.today)
        
      end
      durations.sort!
    end
    durationz
  end


end
