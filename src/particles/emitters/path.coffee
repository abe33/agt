namespace('agt.particles.emitters')
# Public:
class agt.particles.emitters.Path
  @include agt.particles.Randomizable

  ### Public ###

  constructor: (@path, @random) -> @initRandom()

  get: -> @path.pathPointAt @random.get()
