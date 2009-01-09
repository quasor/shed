while true
if ENV['RAILS_ENV'] == 'production'
  puts `curl -s http://s.ectdev.com/tasks/redo`
else
  puts `curl -s http://localhost:3000/tasks/redo`
end
sleep 10
end
