$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'tictactoe-rack/application'
require 'tictactoe-rack/display'

run TicTacToeRack::Application.new(TicTacToeRack::Display.new).rack_app
