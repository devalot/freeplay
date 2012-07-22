class Freeplay::Client < EM::Connection

  ##############################################################################
  include(EM::Protocols::LineText2)

  ##############################################################################
  COMMANDS = {
    'nonce'          => :authenticate_with_nonce,
    'not-authorized' => :not_authorized,
    'opponent'       => :announce_opponent,
    'board'          => :create_board_and_player,
    'move'           => :move,
    'game'           => :game,
    'quit'           => :quit,
  }

  ##############################################################################
  def self.player_class= (klass)
    @@player_class = klass
  end

  ##############################################################################
  def self.logger= (logger)
    @@logger = logger
  end

  ##############################################################################
  def self.username= (username)
    @@username = username
  end

  ##############################################################################
  def post_init
    @@logger.info("connected to server, initiating authentication")
    send_data("authenticate: #{@@username}\n")
  end

  ##############################################################################
  def unbind
    @@logger.info("disconnected from the server")
  end

  ##############################################################################
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
  def authenticate_with_nonce (nonce)
    send_data("nonce-reply: FOOBAR\n")
  end

  ##############################################################################
  def not_authorized (message)
    error(message)
  end

  ##############################################################################
  def announce_opponent (opponent)
    @@logger.info("your opponent is #{opponent}")
  end

  ##############################################################################
  def create_board_and_player (info)
    if m = info.match(/^(white|black)\s+(\d+)$/)
      @board  = Freeplay::Board.new(m[1].to_sym, m[2].to_i)
      @player = @@player_class.new
      @player.board  = @board
      @player.logger = @@logger
    else
      error("server send over invalid game board parameters")
    end
  end

  ##############################################################################
  def move (opponent_move)
    match = opponent_move.match(/^(\d+|none),(\d+|none)$/)

    if match && @player
      @@logger.info("it's your move")

      if match[1] != "none" and match[2] != "none"
        ox, oy = match[1].to_i, match[2].to_i
        @board.opponent_move(ox, oy)
        @@logger.info("opponent's last move was (#{ox},#{oy})")
      end

      player_move = @player.move

      if player_move.is_a?(Array) and player_move.size == 2
        @board.player_move(player_move.first, player_move.last)
        @@logger.info("your move is (#{player_move.first},#{player_move.last})")
        send_data("move: #{player_move.first},#{player_move.last}\n")
      else
        error("#{@@player_class}#move did not return a 2 element array")
      end
    else
      error("server sent an invalid opponent move")
    end
  rescue Freeplay::Error => e
    error(e.message)
  end

  ##############################################################################
  def game (status)
    @@logger.info(status)
  end

  ##############################################################################
  def quit (message)
    @@logger.info("quitting: #{message}")
    EventMachine.stop
  end

  ##############################################################################
  def error (message)
    @@logger.error(message)
    $stderr.puts(message)
    EventMachine.stop
  end
end
