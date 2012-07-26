################################################################################
require('stringio')
require('eventmachine')
require('gtk2')

################################################################################
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
