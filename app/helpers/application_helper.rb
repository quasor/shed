# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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
end
