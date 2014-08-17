namespace('agt.particles.timers')
# Public:
class agt.particles.timers.Limited

  ### Public ###

  constructor: (@duration=1000, @since=0) ->
    @time = 0
    @nextTime = 0

  prepare: (bias, biasInSeconds, time) ->
    unless @firstTime
      @nextTime = @since + bias
      @firstTime = true
    else
      @nextTime = bias
    @time += bias

  finished: -> @time >= @duration
