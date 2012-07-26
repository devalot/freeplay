class Freeplay::Client < EM::Connection

  ##############################################################################
  include(EM::Protocols::LineText2)

  ##############################################################################
  COMMANDS = {
    'nonce'          => :authenticate_with_nonce,
    'not-authorized' => :not_authorized,
    'opponent'       => :announce_opponent,
    'board'          => :create_board_and_player,
    'score'          => :score,
    'move'           => :move,
    'game'           => :game,
    'quit'           => :quit,
  }

  ##############################################################################
  attr_accessor(:player_class, :logger, :username, :gui)

  ##############################################################################
  def self.config= (config)
    @@config = config
  end

  ##############################################################################
  # Connection to server complete.
  def post_init
    self.player_class = @@config.player
    self.logger       = @@config.logger
    self.username     = @@config.options.user
    self.gui          = @@config.options.gui

    logger.info("connected to server, initiating authentication")
    send_data("authenticate: #{username}\n")
  end

  ##############################################################################
  # Dropped connection to server.
  def unbind
    logger.info("disconnected from the server")
    $stderr.puts("done, use Ctrl-C to quit")
  end

  ##############################################################################
  # Incoming message from the server.
  def receive_line (data)
    match = data.match(/^([^:]+):\s+(.+)$/)

    if match and COMMANDS.has_key?(match[1])
      send(COMMANDS[match[1]], match[2])
    else
      error("received an invalid message from the server: #{data}")
    end
  end

  ##############################################################################
  private

  ##############################################################################
  # Suppose to send back a nonce-reply.
  def authenticate_with_nonce (nonce)
    send_data("nonce-reply: FOOBAR\n")
  end

  ##############################################################################
  # Failed authentication.
  def not_authorized (message)
    error(message)
  end

  ##############################################################################
  # We were assigned an opponent.
  def announce_opponent (opponent)
    logger.info("your opponent is #{opponent}")
  end

  ##############################################################################
  # Game preparation, create a board with the given size.  You are
  # also told which stone color you are.
  def create_board_and_player (info)
    if m = info.match(/^(white|black)\s+(\d+)$/)
      @board  = Freeplay::Board.new(m[1].to_sym, m[2].to_i)
      @player = player_class.new
      @player.board  = @board
      @player.logger = logger

      if gui
        self.gui = Freeplay::GUI.new(@board) {EventMachine.stop}
        EventMachine.add_periodic_timer(0.01) {gui.update}
      end
    else
      error("server send over invalid game board parameters")
    end
  end

  ##############################################################################
  # Update the score board.  The first number is the score for the
  # player using white stones, and the second number is the score for
  # the player using black stones.
  def score (details)
    if m = details.match(/^(\d+),(\d+)$/)
      white, black = m[1].to_i, m[2].to_i
      logger.info("score: white=#{white}, black=#{black}")
    else
      error("bad score from the server")
    end
  end

  ##############################################################################
  # Ug, this code is a mess.  Notification that your opponent moved,
  # and that now it's your turn.
  def move (opponent_move)
    match = opponent_move.match(/^(\d+|none),(\d+|none)$/)

    if match && @player
      logger.info("it's your move")

      if match[1] != "none" and match[2] != "none"
        ox, oy = match[1].to_i, match[2].to_i
        @board.opponent_move(ox, oy)
        gui.move(@board.opponent, ox, oy) if gui
        logger.info("opponent's last move was (#{ox},#{oy})")
      end

      player_move = @player.move

      if player_move.is_a?(Array) and player_move.size == 2
        @board.player_move(player_move.first, player_move.last)
        gui.move(@board.player, player_move.first, player_move.last) if gui
        logger.info("your move is (#{player_move.first},#{player_move.last})")
        send_data("move: #{player_move.first},#{player_move.last}\n")
      else
        error("#{player_class}#move did not return a 2 element array")
      end
    else
      error("server sent an invalid opponent move")
    end
  rescue Freeplay::Error => e
    error(e.message)
  end

  ##############################################################################
  # Game over.
  def game (status)
    logger.info(status)

    s = StringIO.new
    @player.board.dump(s)
    logger.debug("Final board state: \n#{s.string}")
  end

  ##############################################################################
  # The server wants us to go away.
  def quit (message)
    logger.info("quitting: #{message}")
    EventMachine.stop
  end

  ##############################################################################
  # Output an error message and die!
  def error (message)
    logger.error(message)
    $stderr.puts(message)
    EventMachine.stop
  end
end