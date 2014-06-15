
SubSystem = agt.particles.SubSystem

class agt.particles.initializers.ParticleSubSystem
  constructor: (initializer, action, emissionFactory, subSystem) ->
    @subSystem = new SubSystem(
      initializer, action, emissionFactory, subSystem
    )

  initialize: (particle) -> @subSystem.emitFor particle
