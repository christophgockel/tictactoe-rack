require 'erb'

require 'tictactoe/game'
require 'tictactoe/board'
require 'tictactoe/player_factory'

class Display
  attr_reader :status, :board, :game_mode
  attr_accessor :move, :game_is_ready, :game_is_ongoing

  def initialize
    @move = nil
    @status = ""
    @board = nil
    @game_is_ready = false
    @game_is_ongoing = false
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
    @move = nil
    the_move
  end

  def can_provide_next_move?
    !@move.nil?
  end

  def game_mode=(mode)
    @game_mode = mode.to_s.split('_').map{ |part| part.capitalize}.join(' vs. ')
  end
end

app = Rack::Builder.new do |env|
  use Rack::Static, urls: ["/css", "/images"], root: "lib/assets"

  display = Display.new
  players = TicTacToe::PlayerFactory.create_pair(:human_computer, display)
  game = nil
  options = {}

  map "/game" do
    map "/" do
      run(Proc.new do |env|
        path = File.expand_path("lib/tictactoe-rack/game.html.erb")
        file = File.read(path)

        content = ERB.new(file)

        display.game_is_ready = game.is_playable?
        display.game_is_ongoing = game.is_ongoing?

        [200, {}, [content.result(display.the_binding)]]
      end)
    end

    map "/new" do
      run(Proc.new do |env|
        request = Rack::Request.new(env)
        options[:board_size] = request.params["board_size"].to_sym
        options[:game_mode] = request.params["game_mode"].to_sym

        display.game_mode = options[:game_mode]

        players = TicTacToe::PlayerFactory.create_pair(options[:game_mode], display)
        game = TicTacToe::Game.new(players.first, players.last, TicTacToe::Board.create(options[:board_size]), display)

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
    map "/restart" do
      run(Proc.new do |env|
        players = TicTacToe::PlayerFactory.create_pair(options[:game_mode], display)
        game = TicTacToe::Game.new(players.first, players.last, TicTacToe::Board.create(options[:board_size]), display)

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
