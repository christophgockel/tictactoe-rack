require "tictactoe-rack/display"

describe TicTacToeRack::Display do
  let(:display) { described_class.new }

  before :each do
    display.move = 42
  end

  it "can accept a move to be used in the next game round" do
    expect(display.can_provide_next_move?).to eq true
  end

  it "provides the next move" do
    expect(display.next_move).to eq 42
  end

  it "resets a move after it has been requested" do
    display.next_move

    expect(display.next_move).to eq 0
  end
end
