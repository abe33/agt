Randomizable = agt.particles.Randomizable

class agt.particles.emitters.Surface
  @include Randomizable

  constructor: (@surface, @random) -> @initRandom()

  get: -> @surface.randomPointInSurface @random
