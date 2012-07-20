class Freeplay::Board

  ##############################################################################
  class OutOfBoundsError  < Freeplay::Error; end
  class InvalidStoneError < Freeplay::Error; end
  class InvalidMoveError  < Freeplay::Error; end

  ##############################################################################
  # The width and height of the game board.  Since the board must be a
  # square the width and height will always be the same.
  attr_reader(:size)

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
  def []= (x, y, val) # :nodoc:
    x, y = transform(x, y)
    bounds_check(x, y)
    move_check(x, y)
    stone_check(val)
    @grid[x][y] = val
  end

  ##############################################################################
  # This method is for internal use only.
  def opponent_move (x, y) # :nodoc:
    x, y = transform(x, y)
    @last_opponent_move = [x, y]
    @grid[x][y] = @opponent
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
      allowed = adjacent(*@last_opponent_move).select do |(x,y)|
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
    [@size - 1 - y, x]
  end

  ##############################################################################
  # Returns all the adjacent stones.
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
end
