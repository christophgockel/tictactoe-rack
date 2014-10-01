class DummyDisplay
  attr_reader :move, :board
  attr_accessor :game_is_playable, :game_is_ongoing, :board

  def show_board(board)
    @board = board
  end

  def announce_next_player(mark)
  end

  def show_invalid_move_message
  end

  def announce_winner(mark)
  end

  def announce_draw
  end

  def can_provide_next_move?
    true
  end

  def next_move
    @move
  end

  def move=(move)
    @move = move
  end

  def the_binding
    binding
  end
end
