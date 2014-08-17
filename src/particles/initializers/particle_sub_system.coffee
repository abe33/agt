namespace('agt.particles.initializers')
# Public:
class agt.particles.initializers.ParticleSubSystem

  ### Public ###

  constructor: (initializer, action, emissionFactory, subSystem) ->
    @subSystem = new agt.particles.SubSystem(
      initializer, action, emissionFactory, subSystem
    )

  initialize: (particle) -> @subSystem.emitFor particle
