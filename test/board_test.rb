################################################################################
require(File.expand_path('helper', File.dirname(__FILE__)))

################################################################################
class BoardTest < Test::Unit::TestCase

  ##############################################################################
  def test_bounds_checking
    board = Freeplay::Board.new(:white, 20)
    assert_equal(:empty, board[0, 0])

    board[0,0] = :white
    assert_equal(:white, board[0,0])

    assert_raise(Freeplay::Board::OutOfBoundsError) {board[-1, 0]}
    assert_raise(Freeplay::Board::OutOfBoundsError) {board[20, 21]}
  end

  ##############################################################################
  def test_stone_checking
    assert_raise(Freeplay::Board::InvalidStoneError) do
      Freeplay::Board.new(:empty)
    end

    board = Freeplay::Board.new(:white)
    assert_raise(Freeplay::Board::InvalidStoneError) {board[0,0] = :black}
    assert_raise(Freeplay::Board::InvalidStoneError) {board[0,0] = :empty}
    assert_raise(Freeplay::Board::InvalidStoneError) {board[0,0] = 'white'}

    board[0,0] = :white
    assert_raise(Freeplay::Board::InvalidMoveError) {board[0,0] = :white}
  end

  ##############################################################################
  def test_adjacency
    board = Freeplay::Board.new(:white)
    board.opponent_move(0, 0)
    board[0, 1] = :white
    board[1, 1] = :white
    board[1, 0] = :white
    board[1, 2] = :white

    board = Freeplay::Board.new(:white)
    board.opponent_move(0, 0)
    assert_raise(Freeplay::Board::InvalidMoveError) {board[1,2] = :white}
  end
end
