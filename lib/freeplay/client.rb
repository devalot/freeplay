class Freeplay::Client < EM::Connection # :nodoc:

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
    'message'        => :show_user_message,
    'game'           => :game,
    'quit'           => :quit,
  }

  ##############################################################################
  attr_accessor(:player_class, :logger, :username, :gui, :ssh_key)

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
    self.ssh_key      = @@config.options.ssh_key

    if gui
      self.gui = Freeplay::GUI.new {EventMachine.stop}
      EventMachine.add_periodic_timer(0.01) {gui.update}
    end

    logger.info("connected to server, initiating authentication")
    send_line("authenticate: #{username}")
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
    digest = Digest::SHA256.file(ssh_key).hexdigest
    reply  = Digest::SHA256.hexdigest(nonce + digest)
    send_line("nonce-reply: #{reply}")
  end

  ##############################################################################
  # Failed authentication.
  def not_authorized (message)
    error(message)
  end

  ##############################################################################
  # We were assigned an opponent.
  def announce_opponent (opponent)
    players = opponent.split(/\s*,\s*/)

    if players.size == 1
      @white_player_name = "You"
      @black_player_name = players.first
    else
      @white_player_name, @black_player_name = players
    end

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
        gui.board = @board
        gui.players(@white_player_name, @black_player_name)
        gui.message("Game in progress...")
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
      gui.score(white, black) if gui
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
        send_line("move: #{player_move.first},#{player_move.last}")
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
  def show_user_message (msg)
    gui.message(msg) if gui
    logger.info("message: #{msg}")
  end

  ##############################################################################
  # Game over.
  def game (info)
    logger.info("game over")

    if (data = info.split(/\s*,\s*/, 3)).size == 3
      winner, white_live, black_live = data
      logger.info("#{winner} won")
      gui.live(parse_live(white_live), parse_live(black_live)) if gui
      gui.message("Game over.")
    else
      error("invalid game over command from server")
    end
  end

  ##############################################################################
  # The server wants us to go away.
  def quit (message)
    logger.info("quitting: #{message}")
    EventMachine.stop
  end

  ##############################################################################
  # Parse the live stone coordinates from the server.
  def parse_live (info)
    info.split(/\s*;\s*/).map {|s| s.split(/\s+/).map {|n| n.to_i}}
  end

  ##############################################################################
  # Send the given message to the server on a single line.
  def send_line (message)
    send_data(message.gsub(/\n+/, ' ') + "\n")
  end

  ##############################################################################
  # Output an error message and die!
  def error (message)
    logger.error(message)
    $stderr.puts(message)
    EventMachine.stop
  end
end
