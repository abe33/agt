namespace('agt.particles.timers')
# Public:
class agt.particles.timers.UntilDeath

  ### Public ###

  constructor: (@particle) ->

  prepare: (bias, biasInSeconds, time) -> @nextTime = bias

  finished: -> @particle.dead
