################################################################################
# The Freeplay::Player class is a base class that all players should
# inherit from.  During game play your class will automatically be
# instantiated and set up with the current game board.
#
# Each time it is your turn to make a move the +move+ method on your
# player object will be called.  The +move+ method is expected to
# return an array of two elements representing the x and y coordinates
# you wish to occupy.
class Freeplay::Player

  ##############################################################################
  # Using the +board+ method you can access the state of the game
  # board and the last move your opponent made.
  #
  #  board[x, y] # => :empty
  #
  #  x, y = board.last_opponent_move
  #
  # For more information see the documentation for the Freeplay::Board
  # class.
  attr_accessor(:board)

  ##############################################################################
  # You can use the logger object to write entries to the log file.
  #
  # For example:
  #
  #   logger.info("I think I'm going to win this time!'")
  attr_accessor(:logger)

  ##############################################################################
  # The +move+ method is called on your player object when it's your
  # turn to move.  The +move+ method is required to return an array of
  # two elements containing the x and y coordinates you with to move
  # to.  Failing to return an array, or returning invalid coordinates
  # will result in your forfeiture.
  def move
    raise(Freeplay::Error, "you didn't write a move method in your player!")
  end

  ##############################################################################
  # Automatically register players when they inherit from this class.
  def self.inherited (klass) # :nodoc:
    players << klass
    super
  end

  ##############################################################################
  # Ignore the man behind the curtain.
  def self.players # :nodoc:
    class << self; self; end.instance_eval {@players ||= []}
  end
end
