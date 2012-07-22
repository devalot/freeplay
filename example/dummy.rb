################################################################################
# This is an example Freeplay player.  It's very dumb, always moving
# to the first open space it can find.
class Dummy < Freeplay::Player

  ##############################################################################
  def move
    x, y = nil, nil

    # First try to move to a space adjacent to my opponent's last move.
    if board.last_opponent_move
      logger.info("searching for an open adjacent space")

      allowed = board.adjacent(*board.last_opponent_move)
      match = allowed.detect {|(ax, ay)| board[ax, ay] == :empty}
      x, y = match if match
    end

    # If that didn't work just take the first available space.
    if x.nil? or y.nil?
      logger.info("searching for first available space")

      x, y = catch(:found_empty_space) do
        board.size.times do |bx|
          board.size.times do |by|
            throw(:found_empty_space, [bx, by]) if board[bx, by] == :empty
          end
        end
      end
    end

    # Return the desired location on the board.
    [x, y]
  end
end
