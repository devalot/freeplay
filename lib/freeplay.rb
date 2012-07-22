################################################################################
require('eventmachine')

################################################################################
module Freeplay

  ##############################################################################
  class Error < RuntimeError; end

  ##############################################################################
  autoload('VERSION', 'freeplay/version')
  autoload('Board',   'freeplay/board')
  autoload('Client',  'freeplay/client')
  autoload('Player',  'freeplay/player')
end
