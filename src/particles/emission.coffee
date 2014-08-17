namespace('agt.particles')

# Public:
class agt.particles.Emission

  ### Public ###

  constructor: (@particleType=agt.particles.Particle,
                @emitter=new agt.particles.timers.NullEmitter(),
                @timer=new agt.particles.counters.NullTimer(),
                @counter=new agt.particles.emitters.NullCounter(),
                @initializer=null) ->

  prepare: (bias, biasInSeconds, time) ->
    @timer.prepare bias, biasInSeconds, time

    nextTime = @timer.nextTime
    @counter.prepare nextTime, nextTime / 1000, time

    @currentCount = @counter.count
    @currentTime = nextTime
    @iterator = 0

  hasNext: -> @iterator < @currentCount

  next: ->
    particle = @particleType.get position: @emitter.get()
    @initializer?.initialize particle
    @iterator++

    particle

  nextTime: -> @currentTime - @iterator / @currentCount * @currentTime

  finished: -> @timer.finished()
