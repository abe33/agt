
class agt.particles.timers.UntilDeath
  constructor: (@particle) ->

  prepare: (bias, biasInSeconds, time) -> @nextTime = bias
  finished: -> @particle.dead
