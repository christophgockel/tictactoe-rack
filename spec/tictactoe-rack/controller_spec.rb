require 'tictactoe/shared_examples'
require 'tictactoe/game'
require 'tictactoe-rack/controller'

describe TicTacToeRack::Controller do
  let(:controller) { described_class.new }

  it 'creates new games based on options' do
    controller.create_game(:board_3x3, :human_human, DummyDisplay.new)
    expect(controller.game).to be_a TicTacToe::Game
  end

  it 'plays a game round' do
    controller.create_game(:board_3x3, :human_human, DummyDisplay.new)

    old_board = controller.board.rows.flatten
    controller.play(1)
    new_board = controller.board.rows.flatten

    expect(new_board).not_to eq old_board
  end

  it 'does not play a game round when no move is provided' do
    controller.create_game(:board_3x3, :human_human, DummyDisplay.new)

    old_board = controller.board.rows.flatten
    controller.play(0)
    new_board = controller.board.rows.flatten

    expect(new_board).to eq old_board
  end

  it 'can restart a running game' do
    controller.create_game(:board_3x3, :human_human, DummyDisplay.new)

    old_board = controller.board.rows.flatten
    controller.play(1)
    controller.restart
    new_board = controller.board.rows.flatten

    expect(new_board).to eq old_board
  end

  context 'DummyDisplay' do
    subject { DummyDisplay.new }
    it_should_behave_like 'a game io object'
  end

  class DummyDisplay
    attr_reader :move

    def show_board(board)
    end

    def announce_next_player(mark)
    end

    def show_invalid_move_message
    end

    def announce_winner(mark)
    end

    def announce_draw
    end

    def can_provide_next_move?
      true
    end

    def next_move
      @move
    end

    def move=(move)
      @move = move
    end
  end
end
