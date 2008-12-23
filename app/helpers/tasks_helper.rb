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
end
