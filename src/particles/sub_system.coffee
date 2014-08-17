namespace('agt.particles')

# Public:
class agt.particles.SubSystem extends agt.particles.System

  ### Public ###

  constructor: (initializer, action, @emissionFactory, subSystem) ->
    super initializer, action, subSystem

  emitFor: (particle) -> @emit @emissionFactory particle
