module Direction

  def diagonal
     [
      [ 1, 1],
      [ 1,-1],
      [-1, 1],
      [-1,-1]
     ]
   end

  def move_down
    [
     [ 1, 1],
     [ 1,-1]
    ]
  end

  def move_up
    [
     [-1, 1],
     [-1,-1]
    ]
  end

end
