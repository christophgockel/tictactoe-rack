require "rack/test"

require "tictactoe-rack/application"
require "tictactoe-rack/dummy_display"

describe TicTacToeRack::Application do
  include Rack::Test::Methods
  let(:display) { DummyDisplay.new }
  let(:application) { described_class.new(display) }

  def app
    application.rack_app
  end

  context "/" do
    it "has a root page" do
      get "/"
      expect(last_response).to be_ok
    end

    it "renders the index template" do
      get "/"
      expect(last_response.body).to include "Tic Rack Toe"
      expect(last_response.body).to include "Play"
    end
  end

  context "/game" do
    before :each do
      get "/"
    end

    context "/" do
      before :each do
        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}
      end

      it "displays a menu button for resetting the game" do
        get "/game"

        expect(last_response).to be_ok
        expect(last_response.body).to include "Restart Game"
      end

      it "displays a menu button for going back" do
        get "/game"

        expect(last_response).to be_ok
        expect(last_response.body).to include "Back"
      end

      it "displays the contents of the board" do
        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}

        application.controller.play(1)
        application.controller.play(2)

        get "/game"

        expect(last_response).to be_ok
        expect(last_response.body).to include "x"
        expect(last_response.body).to include "o"
      end
    end

    context "/new" do
      it "creates a new game" do
        expect(application.controller).to receive(:create_game).with(:board_3x3, :human_human, display)

        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}
      end

      it "redirects to game display" do
        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}

        expect(last_response.redirect?).to eq true
        expect(last_response["Location"]).to eq "/game"
      end
    end

    context "/restart" do
      before :each do
        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}
      end

      it "restarts a game" do
        expect(application.controller).to receive(:restart)

        get "/game/restart"
      end

      it "redirects to game display" do
        get "/game/restart"

        expect(last_response.redirect?).to eq true
        expect(last_response["Location"]).to eq "/game"
      end
    end

    context "/play" do
      before :each do
        get "/game/new", {"board_size" => "board_3x3", "game_mode" => "human_human"}
      end

      it "plays the next round" do
        expect(application.controller).to receive(:play).with(3)

        get "/game/play", {"move" => "3"}
      end

      it "redirects to game display" do
        get "/game/play", {"move" => "3"}

        expect(last_response.redirect?).to eq true
        expect(last_response["Location"]).to eq "/game"
      end
    end
  end
end
