module TicTacToeRack
  class RequestConverter
    def initialize(request)
      @params = request.params
    end

    def move
      @params["move"].to_i
    end

    def board_size
      @params.fetch("board_size").to_sym
    rescue KeyError
      nil
    end

    def game_mode
      @params.fetch("game_mode").to_sym
    rescue KeyError
      nil
    end
  end
end
