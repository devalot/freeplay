# Freeplay: A board game for programmers new to Ruby

The Freeplay game was designed to give new Ruby programmers the chance
to practice their Ruby skills by competing with one another.  This is
only one half of the game, you need to know the address of a game
server in order to actually play.

# The Game

Freeplay is based on the game [Freedom][] which is a two-player board
game with very simple rules.

One player is given a set of white stones and another player is given
a set of black stones.  The player with the white stones moves first,
placing a white stone on any space on the game board.  The players
then alternate, placing their stones on open spaces.

After the first move the rules for placing a stone are as follows:

  1. When placing your stone on the board it must be adjacent to your
     opponent's previously placed stone.

  2. If there are no vacant spaces adjacent to your opponent's
     previously placed stone you may place your stone on any open
     space on the game board.

The game is over when there is a single empty space left on the game
board.  The server will automatically play the last space on behalf of
the player whose turn it is.

If placing a stone in the last empty space increases the score for the
current player, the server will make the move.  Otherwise the space
will remain empty and the game will be terminated.

# Winning the Game

Score is calculated by counting the number of so called "live" stones.
The player with the most live stones wins.

A stone is considered to be live when it is a member of a horizontal,
vertical, or diagonal set of exactly four stones of the same color.

For example, if four black stones were in a horizontal row, all four
stones would count as live.  If a single stone was in a horizontal row
of four and also a vertical row of four, it would be counted as live
twice.

If the set of horizontal, vertical, or diagonal stones is less than
four or greater than four, none of the stones in the set are
considered to be live.

# Writing Your Player Class

In order to participate in the Freeplay tournament you begin by
writing a class that is derived from `Freeplay::Player`.  The class
must have an instance method called `move` which is called when it's
your turn to move.

The `move` method should return a two element array containing the x
and y coordinates of a space for which you wish to place a stone.

For an example player class look at the `example/dummy.rb` file.

# The Game Board

The game board is square and comprised of the same number of
horizontal and vertical spaces.  The size of the board is measured in
the number of horizontal spaces and can vary from game to game.

Coordinates on the board are [Cartesian][] and use an x and y axis.
The x axis is horizontal and the y axis is vertical.  The lower
left-hand corner represents an x value of 0 and a y value of 0.

As you move from left to right the value of x increases.  As you move
from bottom to top the value of y increases.  The x and y coordinates
are written as (x,y).

For example, using a board of size 10, the lower left-hand corner
would be (0,0), the upper left-hand corner (0,9), the upper right-hand
corner (9,9), and the lower right-hand corner would be (9,0).

# Playing the Game

Assuming the name of the game server is `someserver` and the file
containing your player class is `example/dummy.rb`, you would play the
game using the following command line in the terminal:

    freeplay --host someserver example/dummy.rb

Use the `--help` option with the `freeplay` command for more details.

# Installing the Freeplay Gem

    sudo apt-get install libgtk2.0-dev
    sudo gem sources --add http://gems.devalot.com
    sudo gem install freeplay

# Suggestions

  1. Read the `ri` documentation for Freeplay:

        ri Freeplay

  2. Write as many instance methods as necessary to make your player
     code clean and readable.

  3. Read the source code for the `Freeplay::Board` class and see how
     it works.

  4. Don't forget to read the source code for the example player class
     in `example/dummy.rb`.

  5. During game play all of the player actions are recorded into a
     log file named `freeplay.log`.  You will probably want to review
     the log file in order to debug your player's moves.  You can also
     write into this log file using the `logger` method in your player
     class.  See the example player for additional information.

[freedom]: http://en.wikipedia.org/wiki/Freedom_(board_game)
[cartesian]: http://en.wikipedia.org/wiki/Cartesian_coordinate_system
