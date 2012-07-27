################################################################################
# The Freeplay::Board class represents the game board.  Using this
# class you can discover which stone is covering any space on the
# board.
#
# White stones are represented by the symbol +:white+, black stones
# are represented by the symbol +:black+, and spaces that are not
# occupied by any stone are represented by the symbol +:empty+.
#
# The game board uses a Cartesian coordinate system, therefore each
# space on the board can be accessed using x and y coordinates.  The
# bottom left corner of the board has an x value of 0, and a y value
# of zero, which is represented as (x,y) or in this case (0,0).
#
# If the board size is 10, then the upper right corner of the game
# board would be (9,9).  Attempting to move off the board is
# considered an error.
class Freeplay::Board

  ##############################################################################
  class OutOfBoundsError  < Freeplay::Error; end # :nodoc:
  class InvalidStoneError < Freeplay::Error; end # :nodoc:
  class InvalidMoveError  < Freeplay::Error; end # :nodoc:

  ##############################################################################
  # The width and height of the game board.  Since the board must be a
  # square the width and height will always be the same.
  attr_reader(:size)

  ##############################################################################
  # The last move made by the opponent, or nil if the opponent hasn't
  # moved yet.  This is an array of two elements: [x, y].
  attr_reader(:last_opponent_move)

  ##############################################################################
  # Returns the stone color of the primary player.  The stone color
  # will be a symbol, either +:white+ or +:black+.
  attr_reader(:player)

  ##############################################################################
  # Returns the stone color for the primary player's opponent. The
  # stone color will be a symbol, either +:white+ or +:black+.
  attr_reader(:opponent)

  ##############################################################################
  # Don't create a game board yourself.
  def initialize (player, size=10) # :nodoc:
    @player, @size = player, size
    @grid = Array.new(@size) {Array.new(@size, :empty)}
    @opponent = @player == :white ? :black : :white
    @last_opponent_move = nil
    stone_check(@player, [:white, :black])
  end

  ##############################################################################
  # Returns the stone type for the given coordinates.  This method
  # takes two parameters, the first is the x coordinate and the second
  # is the y coordinate.
  #
  # The allowed stone types are :empty, :white, and :black.
  #
  # Example (get the stone in the lower left corner):
  #
  #   board = Freeplay::Board.new(...)
  #   board[0, 0] # => :empty
  #
  def [] (x, y)
    x, y = transform(x, y)
    bounds_check(x, y)
    @grid[x][y]
  end

  ##############################################################################
  # This method is for internal use only.
  def player_move (x, y) # :nodoc:
    x, y = transform(x, y)
    bounds_check(x, y)
    move_check(x, y)
    @grid[x][y] = @player
  end

  ##############################################################################
  # This method is for internal use only.
  def opponent_move (x, y) # :nodoc:
    @last_opponent_move = [x, y]

    x, y = transform(x, y)
    @grid[x][y] = @opponent
  end

  ##############################################################################
  # Returns an array of valid coordinates that are adjacent to the
  # give coordinates.
  def adjacent (x, y)
    transforms = [
      [x    , y + 1], # North
      [x + 1, y + 1], # Northeast
      [x + 1, y    ], # East
      [x + 1, y - 1], # Southeast
      [x    , y - 1], # South
      [x - 1, y - 1], # Southwest
      [x - 1, y    ], # West
      [x - 1, y + 1], # Northwest
    ]

    transforms.select {|t| t.all? {|p| p >= 0 && p < @size}}
  end

  ##############################################################################
  # Dumps a grid to the given output stream.
  def dump (io, options={})
    options = {
      :empty => 'E',
      :white => 'W',
      :black => 'B',
      :error => 'X',
    }.merge!(options)

    @grid.each do |row|
      trans = row.map {|col| options[col] || options[:error]}
      io.puts(trans.join(' '))
    end
  end

  ##############################################################################
  private

  ##############################################################################
  # Ensure the given coordinates are within the grid.
  def bounds_check (x, y)
    if [x, y].any? {|c| c < 0 || c >= @size}
      message = "(#{x},#{y}) is out of bounds, board is #{@size}x#{@size}"
      raise(OutOfBoundsError, message)
    end
  end

  ##############################################################################
  # Ensure the move is valid.
  def move_check (x, y)
    if !@last_opponent_move.nil?
      last = transform(*@last_opponent_move)
      allowed = adjacent(*last).select do |(x,y)|
        @grid[x][y] == :empty
      end

      if !allowed.empty? && !allowed.include?([x, y])
        allowed_str = allowed.map {|(x,y)| "(#{x},#{y})"}.join(', ')
        message  = "move (#{x},#{y}) must be adjacent to "
        message += "(#{@last_opponent_move[0]},#{@last_opponent_move[1]}), "
        message += "allowed moves: " + allowed_str
        raise(InvalidMoveError, message)
      end
    end

    if @grid[x][y] != :empty
      message = "space (#{x},#{y}) already taken with #{@grid[x][y].inspect}"
      raise(InvalidMoveError, message)
    end
  end

  ##############################################################################
  # Ensure the given stone is one of the allowed stones.
  def stone_check (val, allowed=@player)
    allowed = Array(allowed)

    if !allowed.include?(val)
      message  = "invalid stone or player `#{val}' must be"
      message += " one of" if allowed.size != 1
      message += ": "
      message += allowed.map(&:inspect).join(', ')
      raise(InvalidStoneError, message)
    end
  end

  ##############################################################################
  # Transforms grid coordinates to array coordinates.
  def transform (x, y)
    if !x.is_a?(Fixnum) or !y.is_a?(Fixnum)
      message  = "(#{x.inspect},#{y.inspect}) doesn't appear to "
      message += "be valid coordinates, both should be integers"
      raise(OutOfBoundsError, message)
    end

    [@size - 1 - y, x]
  end
end
