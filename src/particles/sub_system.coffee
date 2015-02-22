System = require './system'
# Public:
module.exports =
class SubSystem extends System
  ### Public ###

  constructor: (options={}) ->
    super options
    {@emissionFactory} = options

  emitFor: (particle) -> @emit @emissionFactory particle
