
# Public:
class agt.particles.emitters.Surface
  @include agt.particles.Randomizable

  ### Public ###

  constructor: (@surface, @random) -> @initRandom()

  get: -> @surface.randomPointInSurface @random
