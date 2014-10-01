require 'erb'

require 'tictactoe/game'
require 'tictactoe/board'
require 'tictactoe/player_factory'

require File.dirname(__FILE__) + '/lib/tictactoe-rack/request_converter.rb'
require File.dirname(__FILE__) + '/lib/tictactoe-rack/index_view_model.rb'
require File.dirname(__FILE__) + '/lib/tictactoe-rack/controller.rb'

class Display
  attr_reader :status, :board
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
    @move = 0
    the_move
  end

  def can_provide_next_move?
    return @move != 0
    !@move.nil?
  end
end

app = Rack::Builder.new do |env|
  use Rack::Static, urls: ["/css"], root: "lib/assets"

  display = Display.new
  options = {}
  controller = nil

  map "/game" do
    map "/" do
      run(Proc.new do |env|
        path = File.expand_path("lib/tictactoe-rack/game.html.erb")
        file = File.read(path)

        content = ERB.new(file)

        display.game_is_ready = controller.game.is_playable?
        display.game_is_ongoing = controller.game.is_ongoing?

        [200, {}, [content.result(display.the_binding)]]
      end)
    end

    map "/new" do
      run(Proc.new do |env|
        request = TicTacToeRack::RequestConverter.new(Rack::Request.new(env))
        options[:board_size] = request.board_size
        options[:game_mode] = request.game_mode

        controller.create_game(options[:board_size], options[:game_mode], display)

        [302, {"Location" => "/game"}, []]
      end)
    end

    map "/play" do
      run(Proc.new do |env|
        request = TicTacToeRack::RequestConverter.new(Rack::Request.new(env))
        move = request.move

        display.move = move

        controller.play(move)

        [302, {"Location" => "/game"}, []]
      end)
    end

    map "/restart" do
      run(Proc.new do |env|
        controller.restart

        [302, {"Location" => "/game"}, []]
      end)
    end
  end

  map "/" do
    run(Proc.new do |env|
      path = File.expand_path("lib/tictactoe-rack/index.html.erb")
      file = File.read(path)

      controller = TicTacToeRack::Controller.new
      model = TicTacToeRack::IndexViewModel.new(TicTacToe::Board.available_sizes, TicTacToe::PlayerFactory.available_player_pairs)

      content = ERB.new(file)

      [200, {}, [content.result(model.the_binding)]]
    end)
  end
end

run app
