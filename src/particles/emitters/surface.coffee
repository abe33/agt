{Randomizable} = require '../mixins'
# Public:
module.exports =
class Surface
  @include Randomizable

  ### Public ###

  constructor: (@surface, @random) -> @initRandom()

  get: -> @surface.randomPointInSurface @random
