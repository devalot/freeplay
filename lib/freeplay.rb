################################################################################
require('digest')
require('eventmachine')

################################################################################
# Freeplay is a simple board game played using a server and an
# opponent.  In order to play Freeplay you must write a player class
# and give it to the +freeplay+ command line application.
#
# The classes that you might want to review are:
#
#  - Freeplay::Player
#  - Freeplay::Board
module Freeplay

  ##############################################################################
  class Error < RuntimeError; end

  ##############################################################################
  autoload('VERSION', 'freeplay/version')
  autoload('Board',   'freeplay/board')
  autoload('Client',  'freeplay/client')
  autoload('GUI',     'freeplay/gui')
  autoload('Player',  'freeplay/player')
end
