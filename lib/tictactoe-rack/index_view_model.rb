module TicTacToeRack
  class IndexViewModel
    def initialize(board_sizes, game_modes)
      @board_sizes = board_sizes
      @game_modes  = game_modes
    end

    def board_sizes
      Hash[ @board_sizes.map{ |size_key| [size_key, board_size_text(size_key)] }]
    end

    def game_modes
      Hash[ @game_modes.map { |mode_key| [mode_key, game_mode_text(mode_key)] }]
    end

    def the_binding
      binding
    end

    private

    def board_size_text(size_key)
      size_key
        .to_s
        .split('_')
        .last
    end

    def game_mode_text(mode_key)
      mode_key
        .to_s
        .split('_')
        .map { |part| part.capitalize }
        .join(' vs. ')
    end
  end
end
