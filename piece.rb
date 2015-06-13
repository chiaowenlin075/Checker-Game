# encoding: utf-8
require_relative 'direction'
require 'colorize'
require 'byebug'


class Piece
  include Direction

  attr_accessor :board, :pos, :crown, :symbol_figure
  attr_reader :color

  def initialize(board, color, pos, crown = false)
    @board, @color, @pos, @crown = board, color, pos, crown
    @symbol_figure = symbol
  end

  def valid_slide # filter out invalid new pos # checked!
    moveable = []
    move_diffs.each do |dt_row, dt_col|
      new_pos = [ pos[0] + dt_row, pos[1] + dt_col ]
      moveable << new_pos if board.in_board?(new_pos) && board[new_pos].nil?
    end

    moveable
  end

  def valid_jump
    moveable = []
    move_diffs.each do |dt_row, dt_col|
      enemy_pos = [ pos[0] + dt_row, pos[1] + dt_col ]
      next unless board.in_board?(enemy_pos) && enemy_jumpover?(enemy_pos)
      destination = [ enemy_pos[0] + dt_row, enemy_pos[1] + dt_col ]
      next unless board.in_board?(destination) && board[destination].nil?
      moveable << destination
    end

    moveable
  end

  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError.new("Move fails")
    end
  end

  private

  def symbol
    '⬤'.colorize(color)
  end

  def enemy_jumpover?(enemy_pos)
    !board[enemy_pos].nil? && board[enemy_pos].color != color
  end

  def valid_move_seq?(move_sequence)
    check_board = board.deep_dup
    check_piece = check_board[pos]

    begin
      check_piece.perform_moves!(move_sequence)
      return true
    rescue InvalidMoveError
      return false
    end
  end

  def crowned
    if pos[0] == (color == :blue ? 7 : 0)
      self.crown = true
      self.symbol_figure = '♛'.colorize(color)
    end
  end

  def perform_slide(new_pos) # true/ false # checked!
    return false unless valid_slide.include?(new_pos)

    board.put_piece(new_pos, self)
    crowned
    true
  end

  def perform_jump(new_pos) # true/ false, remove the jumped piece from the Board
    return false unless valid_jump.include?(new_pos)

    enemy_pos = [(new_pos[0] + pos[0]) / 2, (new_pos[1] + pos[1]) / 2]
    board[enemy_pos] = nil
    board.put_piece(new_pos, self)
    crowned
    true
  end

  def move_diffs # returned all the directions a piece could move in # checked!
    return diagonal if crown == true
    color == :blue ? move_down : move_up
  end

  protected

  def perform_moves!(move_sequence) #move_sequence is a 2D array with all the pos you want to move
    if move_sequence.size == 1 && valid_slide.include?(move_sequence[0])
      perform_slide(move_sequence[0])
    else
      move_sequence.each do |new_pos|
        if valid_jump.include?(new_pos)
          perform_jump(new_pos)
        else
          raise InvalidMoveError.new("Move fails")
        end
      end
    end
  end


end

class InvalidMoveError < StandardError
end
