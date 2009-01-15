# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged_in?
	controller.logged_in?
  end
  def admin?
	  controller.admin?
  end
  def current_user
	  controller.current_user
  end
  
  def render_nested_set( node, i )
    c = node.children
    
    "<li>#{visit_node(node,i)}" + ("<ul>" unless c.nil?) + node.children.collect { |n| render_nested_set(n,i) }.join + ("</ul>" unless c.nil?) 
  end
  def visit_node( node, i )
    if i == node.id
      content_tag :b, node.title
    else
      link_to node.title, :p => node.id
    end 
  end
  def link_to_current_task(name = nil)
  	s = "<a href=\"javascript:newwindow=window.open('#{user_path(current_user,:timer=> true, :task_id => current_user.current_task)}','','resizable=1,toolbar=0,location=0,status=0,menubar=0,scrollbars=1,width=275,height=450');newwindow.focus();\" id=\"timer-link\">"
    if current_user.current_task
      if name == nil
	      s = s + "In Progress: " + truncate(current_user.current_task.title,20)
      else
        s = s + name
      end
	  else 
	    s = s + "My Tasks"
    end
	  s = s + "</a>"
  end
  
  def link_to(*args, &block)
    if block_given?
      concat super(capture(&block), *args), block.binding
    else
      super(*args)
    end
  end

end
