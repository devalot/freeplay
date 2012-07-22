################################################################################
require(File.expand_path('helper', File.dirname(__FILE__)))

################################################################################
class BoardTest < Test::Unit::TestCase

  ##############################################################################
  def test_bounds_checking
    board = Freeplay::Board.new(:white, 20)
    assert_equal(:empty, board[0, 0])

    board.player_move(0,0)
    assert_equal(:white, board[0,0])

    assert_raise(Freeplay::Board::OutOfBoundsError) {board[-1, 0]}
    assert_raise(Freeplay::Board::OutOfBoundsError) {board[20, 21]}
  end

  ##############################################################################
  def test_adjacency
    board = Freeplay::Board.new(:white)
    board.opponent_move(0, 0)
    board.player_move(0, 1)
    board.player_move(1, 1)
    board.player_move(1, 0)
    board.player_move(1, 2)

    board = Freeplay::Board.new(:white)
    board.opponent_move(0, 0)
    assert_raise(Freeplay::Board::InvalidMoveError) {board.player_move(1,2)}
  end
end
