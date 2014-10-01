require "tictactoe-rack/index_view_model"

describe TicTacToeRack::IndexViewModel do
  let(:model) { described_class.new([:size_1, :size_2, :size_3], [:a_b, :b_c, :d_a]) }

  it "provides a hash of board sizes with texts" do
    expect(model.board_sizes).to eq({
      :size_1 => "1",
      :size_2 => "2",
      :size_3 => "3"
    })
  end

  it "provides a hash of game modes with texts" do
    expect(model.game_modes).to eq({
      :a_b => "A vs. B",
      :b_c => "B vs. C",
      :d_a => "D vs. A"
    })
  end
end
