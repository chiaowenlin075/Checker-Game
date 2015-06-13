# encoding: utf-8
require_relative 'piece'

class Board

  ROW = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3,
    "E" => 4,
    "F" => 5,
    "G" => 6,
    "H" => 7
  }

  GRIDSIZE = 8

  attr_accessor :grid

  def initialize(blank_grid = true)
    @grid = (blank_grid == true ? make_grid : Array.new(GRIDSIZE) { Array.new (GRIDSIZE) })
  end


  def [](pos)
    raise 'Invalid pos' unless in_board?(pos)
    row, col = pos
    grid[row][col]
  end

  def []=(pos, piece)
    raise 'Invalid pos' unless in_board?(pos)

    row, col = pos
    grid[row][col] = piece
  end

  def won_team # return true, then red win!
    if pieces.all? {|el| el.color == :blue } || no_valid_move?(:red)
      "blue"
    elsif pieces.all? {|el| el.color == :red } || no_valid_move?(:blue)
      "red"
    else
      nil
    end
  end

  def no_valid_move?(color)
    pieces.all? do |piece|
      next unless piece.color == color
      piece.valid_slide.empty? && piece.valid_jump.empty?
    end
  end

  def put_piece(new_pos, piece)
    self[new_pos] = piece
    self[piece.pos] = nil
    piece.pos = new_pos
  end

  def in_board?(pos)
    pos.all? { |idx| idx.between?(0, GRIDSIZE - 1) }
  end


  def display
    puts "   #{ROW.values.map{|idx| idx + 1}.join(" ")}"
    GRIDSIZE.times do |row|
      print "#{ROW.keys[row]} "
      GRIDSIZE.times do |col|
        background = ( (row + col).even? ? :while : :black )
        print (self[[row,col]].nil? ? "  ".colorize( :background => background) : "#{self[[row,col]].symbol_figure} ".colorize( :background => background))
      end
      puts " #{ROW.keys[row]}"
    end
    puts "  #{ROW.values.map{|idx| idx + 1}.join(" ")}"
  end


  def deep_dup
    new_board = Board.new #(false)
    new_board.grid = Array.new(GRIDSIZE) { Array.new (GRIDSIZE) }

    pieces.each do |piece|
      new_board[piece.pos] = Piece.new(new_board, piece.color, piece.pos.dup, piece.crown)
    end

    new_board
  end

  private

  def make_grid
    grid = Array.new(GRIDSIZE) { Array.new (GRIDSIZE) }

    [0, 1, 2, 5, 6, 7].each do |row|
      [0, 2, 4, 6].each do |col|
        col = col + row % 2
        color = (row < 3 ? :blue : :red )
        grid[row][col] = Piece.new(self, color, [row, col])
      end
    end

    grid
  end

  def pieces
    grid.flatten.compact
  end

end
