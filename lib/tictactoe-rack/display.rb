module TicTacToeRack
  class Display
    attr_reader :status, :board
    attr_accessor :move, :game_is_playable, :game_is_ready, :game_is_ongoing

    def initialize
      @move = 0
      @status = ""
      @board = nil
      @game_is_ongoing = false
      @game_is_playable = false
      @game_mode = ""
    end

    def the_binding
      binding
    end

    def show_board(board)
      @board = board
    end

    def show_invalid_move_message
      @status = "Invalid move"
    end

    def announce_next_player(mark)
      @status = "Next player: #{mark}"
    end

    def announce_winner(mark)
      @status = "Winner is: #{mark}"
    end

    def announce_draw
      @status = "Game ended in a draw."
    end

    def next_move
      the_move = @move
      @move = 0
      the_move
    end

    def can_provide_next_move?
      @move != 0
    end
  end
end
