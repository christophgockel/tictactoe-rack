require 'erb'
require 'sprockets'

require 'tictactoe-rack/controller'
require 'tictactoe-rack/index_view_model'
require 'tictactoe-rack/request_converter'

module TicTacToeRack
  class Application
    attr_reader :display, :controller

    def initialize(display)
      @display = display
      @controller = Controller.new
    end

    def rack_app
      display = @display
      controller = @controller

      Rack::Builder.new do |env|
#        use Rack::Static, urls: ["/css"], root: "lib/assets"

        map "/assets" do
          environment = Sprockets::Environment.new
          environment.append_path 'lib/assets/js'
          environment.append_path 'lib/assets/css'
          run environment
        end

        map "/" do
          run(Proc.new do |env|
            path = File.expand_path("lib/tictactoe-rack/index.html.erb")
            file = File.read(path)

            model = IndexViewModel.new(TicTacToe::Board.available_sizes, TicTacToe::PlayerFactory.available_player_pairs)

            content = ERB.new(file)

            [200, {}, [content.result(model.the_binding)]]
          end)
        end

        map "/game" do
          map "/" do
            run(Proc.new do |env|
              path = File.expand_path("lib/tictactoe-rack/game.html.erb")
              file = File.read(path)

              content = ERB.new(file)

              display.game_is_ongoing = controller.game.is_ongoing?
              display.game_is_playable = controller.game.is_playable?

              [200, {}, [content.result(display.the_binding)]]
            end)
          end

          map "/new" do
            run(Proc.new do |env|
              request = TicTacToeRack::RequestConverter.new(Rack::Request.new(env))

              controller.create_game(request.board_size, request.game_mode, display)

              [302, {"Location" => "/game"}, []]
            end)
          end

          map "/restart" do
            run(Proc.new do |env|
              controller.restart

              [302, {"Location" => "/game"}, []]
            end)
          end

          map "/play" do
            run(Proc.new do |env|
              begin
                request = TicTacToeRack::RequestConverter.new(Rack::Request.new(env))
                controller.play(request.move)
              ensure
                next [302, {"Location" => "/game"}, []]
              end
            end)
          end
        end
      end.to_app
    end
  end
end
