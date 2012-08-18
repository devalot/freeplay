################################################################################
# http://ruby-gnome2.sourceforge.jp/hiki.cgi?Ruby%2FGTK
require('gtk2')

################################################################################
class Freeplay::GUI #:nodoc:

  ##############################################################################
  WINDOW_TITLE = 'Freeplay Game'

  ##############################################################################
  COLORS_NORMAL = {
    :white => Gdk::Color.parse("#ffffff"),
    :black => Gdk::Color.parse("#000000"),
  }

  ##############################################################################
  COLORS_LIVE = {
    :white => Gdk::Color.parse("#f0e68c"),
    :black => Gdk::Color.parse("#8b5a2b"),
  }

  ##############################################################################
  def initialize (&quit)
    self.board = Freeplay::Board.new(:white)
    @window = create_window(&quit)
    @window.show_all
  end

  ##############################################################################
  def board= (board)
    @board = board
    reset

    if @table
      @container.remove(@table)
      @container.pack_start(@table = create_table, true)
      @container.reorder_child(@table, 1)
      @container.show_all
    end
  end

  ##############################################################################
  def update
    Gtk::main_iteration while Gtk::events_pending?
  end

  ##############################################################################
  def move (player, x, y)
    opponent = player == :black ? :white : :black
    x, y = transform(x, y)
    bg, fg = COLORS_NORMAL[player], COLORS_NORMAL[opponent]

    update_color(x, y, bg, fg, @counts[player])
    @counts[player] += 1
  end

  ##############################################################################
  def players (white, black)
    @players = {white: white, black: black}
    score(*@score.values)
  end

  ##############################################################################
  def message (msg)
    @messages.text = msg
  end

  ##############################################################################
  def score (white, black)
    @score = {white: white, black: black}

    @score.each do |color, score|
      label = @score_labels[color]
      label.text = @players[color] + ": #{score}"
    end
  end

  ##############################################################################
  def live (white_live, black_live)
    update_live_stones(:white, white_live)
    update_live_stones(:black, black_live)
  end

  ##############################################################################
  private

  ##############################################################################
  def reset
    @counts  = {white: 1,              black: 1}
    @score   = {white: 0,              black: 0}
    @players = {white: "White Stones", black: "Black Stones"}
  end

  ##############################################################################
  def create_window (&quit)
    window = Gtk::Window.new
    window.border_width = 10
    window.set_size_request(400, -1)
    window.title = WINDOW_TITLE

    window.signal_connect("delete_event", &quit)
    window.signal_connect("destroy", &quit)

    @messages = Gtk::Label.new("Waiting for game to start...")
    @messages.justify = Gtk::JUSTIFY_LEFT
    msg_box = Gtk::Fixed.new
    msg_box.put(@messages, 0, 2)

    @container = Gtk::VBox.new(false, 4)
    @container.pack_start(create_score_labels, false)
    @container.pack_start(@table = create_table, true)
    @container.pack_start(msg_box, false)

    window.add(@container)
    window
  end

  ##############################################################################
  def create_score_labels
    box = Gtk::HBox.new(false, 4)

    @score_labels = {
      white: Gtk::Label.new(""),
      black: Gtk::Label.new(""),
    }

    @score_labels.values.each do |label|
      label.justify = Gtk::JUSTIFY_CENTER
      box.add(label)
    end

    score(0, 0)
    box
  end

  ##############################################################################
  # Create a table that contains Gtk::EventBox objects, which contain
  # Gtk::Label objects.  The labels will show the order in which moves
  # were made, and the event boxes will show the color of the stone in
  # that box.
  def create_table
    @grid = Array.new(@board.size) {Array.new(@board.size, nil)}

    table = Gtk::Table.new(@board.size, @board.size, true)
    t_options = Gtk::EXPAND | Gtk::FILL

    @board.size.times do |x|
      @board.size.times do |y|
        @grid[x][y] = {:box => Gtk::EventBox.new, :label => Gtk::Label.new("")}
        @grid[x][y][:box].add(@grid[x][y][:label])
        table.attach(@grid[x][y][:box], x, x+1, y, y+1, t_options, t_options, 0, 0)
      end
    end

    table
  end

  ##############################################################################
  def update_live_stones (color, coordinates)
    opposite = color == :white ? :black : :white

    coordinates.each do |(x, y)|
      tx, ty = transform(x, y)
      update_color(tx, ty, COLORS_LIVE[color], COLORS_NORMAL[opposite])
    end
  end

  ##############################################################################
  def update_color (x, y, bg, fg, count=nil)
    cell = @grid[x][y]
    cell[:box].modify_bg(Gtk::STATE_NORMAL,   bg)
    cell[:label].modify_fg(Gtk::STATE_NORMAL, fg)
    cell[:label].text = count.to_s if count
  end

  ##############################################################################
  # Translates game board coordinates to GTK table coordinates.
  def transform (x, y)
    [x, @board.size - 1 - y]
  end
end
