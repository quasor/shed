module NestedSetList
  def first_item?
    parent.nil? or parent.lft==self.lft-1
  end
  def first?
    parent.nil? or parent.lft==self.lft-1
  end
  def last?
    parent.nil? or parent.rgt==self.rgt+1
  end
  def higher_item
    list = self_and_siblings
    i = list.index(self)
    i==0 ? self : list[ i-1 ]
  end
  def lower_item
    list = self_and_siblings
    i = list.index(self)
    i==list.size-1 ? self : list[ i+1 ]
  end
  def move_higher
    move_to_left_of( higher_item ) if higher_item
  end
  def move_lower
    move_to_right_of( lower_item ) if lower_item
  end
  def move_to_top
    move_to_left_of( self_and_siblings.first ) unless first?
  end
  def move_to_bottom
    move_to_right_of( self_and_siblings.last ) unless last?
  end
end