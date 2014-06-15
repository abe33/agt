class agt.particles.SubSystem extends agt.particles.System
  constructor: (initializer, action, @emissionFactory, subSystem) ->
    super initializer, action, subSystem

  emitFor: (particle) -> @emit @emissionFactory particle
