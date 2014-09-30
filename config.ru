require 'erb'

require 'tictactoe/game'
require 'tictactoe/board'
require 'tictactoe/player_factory'

class Display
  attr_reader :status, :board
  attr_accessor :move, :game_is_ready

  def initialize
    @move = nil
    @status = ""
    @board = nil
    @game_is_ready = false
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
    @move = nil
    the_move
  end

  def can_provide_next_move?
    !@move.nil?
  end
end

app = Rack::Builder.new do |env|
  use Rack::Static, urls: ["/css", "/images"], root: "lib/assets"

  display = Display.new
  players = TicTacToe::PlayerFactory.create_pair(:human_computer, display)
  game = nil

  map "/restart" do
    run(Proc.new do |env|
      game = TicTacToe::Game.new(players.first, players.last, TicTacToe::Board.create(:board_3x3), display)

      [302, {"Location" => "/game"}, []]
    end)
  end

  map "/game" do
    map "/" do
      run(Proc.new do |env|
        path = File.expand_path("lib/tictactoe-rack/game.html.erb")
        file = File.read(path)

        content = ERB.new(file)
        display.game_is_ready = game.is_playable?

        [200, {}, [content.result(display.the_binding)]]
      end)
    end

    map "/new" do
      run(Proc.new do |env|
        request = Rack::Request.new(env)
        board_size = request.params["board_size"].to_sym
        game_mode = request.params["game_mode"].to_sym

        players = TicTacToe::PlayerFactory.create_pair(game_mode, display)

        game = TicTacToe::Game.new(players.first, players.last, TicTacToe::Board.create(board_size), display)

        [302, {"Location" => "/game"}, []]
      end)
    end

    map "/play" do
      run(Proc.new do |env|
        request = Rack::Request.new(env)
        move = request.params["move"].to_i

        display.move = move

        game.play_next_round

        [302, {"Location" => "/game"}, []]
      end)
    end
  end

  map "/" do
    run(Proc.new do |env|
      request = Rack::Request.new(env)
      path = File.expand_path("lib/tictactoe-rack/index.html.erb")
      file = File.read(path)

      content = ERB.new(file)

      [200, {}, [content.result(display.the_binding)]]
    end)
  end
end

run app
