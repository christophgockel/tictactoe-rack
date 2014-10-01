require 'tictactoe-rack/request_converter'

describe TicTacToeRack::RequestConverter do
  it "normalizes request parameters" do
    converter = described_class.new(FakeRequest.new({"move" => "2"}))
    expect(converter.move).to eq 2
  end

  it "defaults to zero for integer values" do
    converter = described_class.new(FakeRequest.new({}))
    expect(converter.move).to eq 0
  end

  it "returns symbol for board size" do
    converter = described_class.new(FakeRequest.new({"board_size" => "board_3x3"}))
    expect(converter.board_size).to eq :board_3x3
  end

  it "returns symbol for board size" do
    converter = described_class.new(FakeRequest.new({"game_mode" => "human_computer"}))
    expect(converter.game_mode).to eq :human_computer
  end

  it "returns nil when board_size is not available" do
    converter = described_class.new(FakeRequest.new({}))
    expect(converter.board_size).to eq nil
  end

  it "returns nil when game_mode is not available" do
    converter = described_class.new(FakeRequest.new({}))
    expect(converter.game_mode).to eq nil
  end

  class FakeRequest
    def initialize(parameters)
      @parameters = parameters
    end

    def params
      @parameters
    end
  end
end
