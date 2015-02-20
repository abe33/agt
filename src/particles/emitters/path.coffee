{Randomizable} = require '../mixins'
# Public:
module.exports =
class Path
  @include Randomizable

  ### Public ###

  constructor: (@path, @random) -> @initRandom()

  get: -> @path.pathPointAt @random.get()
