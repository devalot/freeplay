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
  def initialize (board, &quit)
    @board = board
    @counts = {white: 1, black: 1}
    @grid = Array.new(@board.size) {Array.new(@board.size, nil)}
    @window = create_window(&quit)
    @window.show_all
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
  def live (white_live, black_live)
    update_live_stones(:white, white_live)
    update_live_stones(:black, black_live)
  end

  ##############################################################################
  private

  ##############################################################################
  def create_window (&quit)
    window = Gtk::Window.new
    window.border_width = 10
    window.set_size_request(400, -1)
    window.title = WINDOW_TITLE

    window.signal_connect("delete_event", &quit)
    window.signal_connect("destroy", &quit)

    window.add(create_table)
    window
  end

  ##############################################################################
  # Create a table that contains Gtk::EventBox objects, which contain
  # Gtk::Label objects.  The labels will show the order in which moves
  # were made, and the event boxes will show the color of the stone in
  # that box.
  def create_table
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
