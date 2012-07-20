################################################################################
module Freeplay

  ##############################################################################
  class Error < RuntimeError; end

  ##############################################################################
  autoload('VERSION', 'freeplay/version')
  autoload('Board',   'freeplay/board')
  autoload('Player',  'freeplay/player')
end
