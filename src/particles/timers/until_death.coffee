
# Public:
module.exports =
class UntilDeath

  ### Public ###

  constructor: (@particle) ->

  prepare: (bias, biasInSeconds, time) -> @nextTime = bias

  finished: -> @particle.dead
