Randomizable = agt.particles.Randomizable

class agt.particles.emitters.Path
  @include Randomizable

  constructor: (@path, @random) -> @initRandom()

  get: -> @path.pathPointAt @random.get()
