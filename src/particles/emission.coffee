
Particle = agt.particles.Particle
NullTimer = agt.particles.timers.NullTimer
NullCounter = agt.particles.counters.NullCounter
NullEmitter = agt.particles.emitters.NullEmitter

# Public:
class agt.particles.Emission

  ### Public ###

  constructor: (@particleType=Particle,
                @emitter=new NullEmitter(),
                @timer=new NullTimer(),
                @counter=new NullCounter(),
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
