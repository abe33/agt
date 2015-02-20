SubSystem = require '../sub_system'
# Public:
module.exports =
class ParticleSubSystem

  ### Public ###

  constructor: (initializer, action, emissionFactory, subSystem) ->
    @subSystem = new SubSystem(initializer, action, emissionFactory, subSystem)

  initialize: (particle) -> @subSystem.emitFor particle
