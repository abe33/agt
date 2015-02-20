System = require './system'
# Public:
module.exports =
class SubSystem extends System
  ### Public ###

  constructor: (initializer, action, @emissionFactory, subSystem) ->
    super initializer, action, subSystem

  emitFor: (particle) -> @emit @emissionFactory particle
