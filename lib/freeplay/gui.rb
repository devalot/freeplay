class Freeplay::GUI

  ##############################################################################
  WINDOW_TITLE = 'Freeplay Game'

  ##############################################################################
  COLORS_NORMAL = {
    :black => Gdk::Color.parse("#000000"),
    :white => Gdk::Color.parse("#ffffff"),
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
    x, y = @board.send(:transform, x, y)

    cell = @grid[x][y]
    cell[:label].text = @counts[player].to_s
    cell[:box].modify_bg(Gtk::STATE_NORMAL,   COLORS_NORMAL[player])
    cell[:label].modify_fg(Gtk::STATE_NORMAL, COLORS_NORMAL[opponent])

    @counts[player] += 1
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
end
