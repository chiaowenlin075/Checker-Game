require_relative 'board'

class Checker

  attr_reader :board
  attr_accessor :current_player

  def initialize
    @board = Board.new
    @current_player = :blue
  end

  def play
    loop do
      begin
        board.display
        move_piece = choose_piece
      rescue NotValidPiece
        puts "Not a valid position, please choose again: "
        retry
      end

      begin
        move_sequence = choose_moves
        next if move_sequence == 'rechoose'
        move_piece.perform_moves(move_sequence)
      rescue InvalidMoveError
        puts "Move fail, please choose move again or \'q\' to choose another piece"
        retry
      rescue NoInput
        puts "You didn't type in your moves, please choose again or \'q\' to choose another piece: "
        retry
      rescue NotValidMoveInput
        puts "Not a valid input, please choose again or \'q\' to choose another piece: "
        retry
      end

      unless board.won_team.nil?
        board.display
        puts "Congrat! Team #{board.won_team} win!"
        break
      end
      self.current_player = ( current_player == :blue ? :red : :blue )
    end
  end


  def choose_piece
    puts "Team #{current_player}, please choose a piece to move (Ex: A2): "
    piece = gets.chomp.strip.split("")
    if Board::ROW.has_key?(piece[0].upcase) && piece.size == 2
      piece = board[[ Board::ROW[piece[0].upcase], piece[1].to_i - 1]]
      if !piece.nil? && piece.color == current_player
        return piece
      else
        raise NotValidPiece
      end
    else
      raise NotValidPiece.new("Not a valid piece!")
      # puts "Not a valid position, please choose again: "
    end
  end

  def choose_moves
    puts "Please type in the places you want to move (Ex: A2, B3) or \'q\' to choose another piece: "
    move_sequence = gets.chomp.strip.split(",").map(&:strip)
    if move_sequence.empty?
      raise NoInput.new("No input.")
    else
      move_sequence = move_sequence.map { |el| el.split("") }
      return 'rechoose' if move_sequence[0] == ["q"]
      if move_sequence.all? { |move| Board::ROW.has_key?(move[0].upcase) && ("1".."#{Board::GRIDSIZE}").include?(move[1]) && move.size == 2}
        return move_sequence = move_sequence.map { |move| move = Board::ROW[move[0].upcase], move[1].to_i - 1 }
      else
        raise NotValidMoveInput.new("Not a valid move choice!")
      end
    end
  end
end

class NotValidMoveInput < StandardError
end

class NotValidPiece < StandardError
end

class NoInput < StandardError
end
