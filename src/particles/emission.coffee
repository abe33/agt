Particle = require './particle'
NullTimer = require './timers/null_timer'
NullEmitter = require './emitters/null_emitter'
NullCounter = require './counters/null_counter'

# Public:
module.exports =
class Emission

  ### Public ###

  constructor: (options={}) ->
    options.emitter ?= new NullEmitter()
    options.timer ?= new NullTimer()
    options.counter ?= new NullCounter()

    {@class, @emitter, @timer, @counter, @initializer, @action} = options

  prepare: (bias, biasInSeconds, time) ->
    @timer.prepare bias, biasInSeconds, time
    @action?.prepare bias, biasInSeconds, time

    nextTime = @timer.nextTime
    @counter.prepare nextTime, nextTime / 1000, time

    @currentCount = @counter.count
    @currentTime = nextTime
    @iterator = 0

  hasNext: -> @iterator < @currentCount

  next: ->
    particle = @class.get position: @emitter.get(), emission: this
    @initializer?.initialize particle
    @iterator++

    particle

  nextTime: -> @currentTime - @iterator / @currentCount * @currentTime

  finished: -> @timer.finished()
