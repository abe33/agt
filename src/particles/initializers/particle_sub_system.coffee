SubSystem = require '../sub_system'
# Public:
module.exports =
class ParticleSubSystem

  ### Public ###

  constructor: (options={}) ->
    @subSystem = new SubSystem(options)

  initialize: (particle) -> @subSystem.emitFor particle
