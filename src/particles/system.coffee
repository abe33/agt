NullInitializer = require './initializers/null_initializer'
NullAction = require './actions/null_action'
Signal = require '../signal'
Impulse = require '../impulse'

# Public:
module.exports =
class System

  ### Public ###

  constructor: (options={}) ->
    options.initializer ?= new NullInitializer
    options.action ?= new NullAction

    {@initializer, @action, @subSystem} = options

    @particlesCreated = new Signal
    @particlesDied = new Signal
    @emissionStarted = new Signal
    @emissionFinished = new Signal
    @particles = []
    @emissions = []

  emitting: -> @emissions.length > 0

  emit: (emission) ->
    @emissions.push emission
    emission.system = this
    @startEmission emission

  start: ->
    unless @running
      Impulse.instance().add @tick, this
      @running = true

  stop: ->
    if @running
      Impulse.instance().remove @tick, this
      @running = false

  tick: (bias, biasInSeconds, time) ->
    @died = []
    @created = []

    @processParticles bias, biasInSeconds, time
    @particlesDied.dispatch this, @died if @died.length > 0
    @processEmissions bias, biasInSeconds, time if @emitting()

    @particlesCreated.dispatch this, @created if @created.length > 0
    @particlesDied.dispatch this, @died if @died.length > 0
    particle.constructor.release particle for particle in @died

    @died = null
    @created = null

  ##    ######## ##     ## ####  ######   ######  ####  #######  ##    ##
  ##    ##       ###   ###  ##  ##    ## ##    ##  ##  ##     ## ###   ##
  ##    ##       #### ####  ##  ##       ##        ##  ##     ## ####  ##
  ##    ######   ## ### ##  ##   ######   ######   ##  ##     ## ## ## ##
  ##    ##       ##     ##  ##        ##       ##  ##  ##     ## ##  ####
  ##    ##       ##     ##  ##  ##    ## ##    ##  ##  ##     ## ##   ###
  ##    ######## ##     ## ####  ######   ######  ####  #######  ##    ##

  startEmission: (emission) ->
    emission.prepare 0, 0, @getTime()
    @created = []
    @died = []

    @start() unless @running
    @processEmission emission

    @emissionStarted.dispatch this, emission
    @particlesCreated.dispatch this, @created if @created.length > 0
    @particlesDied.dispatch this, @died if @died.length > 0

    @died = null
    @created = null

  removeEmission: (emission) ->
    if emission in @emissions
      @emissions.splice @emissions.indexOf(emission), 1

  removeAllEmissions: ->
    @emissions = []

  processEmissions: (bias, biasInSeconds, time) ->
    for emission in @emissions.concat()
      emission.prepare bias, biasInSeconds, time
      @processEmission emission

  processEmission: (emission) ->
    while emission.hasNext()
      time = emission.nextTime()
      particle = emission.next()
      particle.system = this
      @created.push particle
      @registerParticle particle
      @initializeParticle particle, time
      if emission.finished()
        @removeEmission emission
        @emissionFinished.dispatch this, emission

  ##    ########     ###    ########  ######## ####  ######  ##       ########
  ##    ##     ##   ## ##   ##     ##    ##     ##  ##    ## ##       ##
  ##    ##     ##  ##   ##  ##     ##    ##     ##  ##       ##       ##
  ##    ########  ##     ## ########     ##     ##  ##       ##       ######
  ##    ##        ######### ##   ##      ##     ##  ##       ##       ##
  ##    ##        ##     ## ##    ##     ##     ##  ##    ## ##       ##
  ##    ##        ##     ## ##     ##    ##    ####  ######  ######## ########

  processParticles: (bias, biasInSeconds, time) ->
    @action.prepare bias, biasInSeconds, time
    for particle in @particles.concat()
      @action.process particle
      particle.emission?.action?.process(particle)
      @unregisterParticle particle if particle.dead

  initializeParticle: (particle, time) ->
    @initializer.initialize particle
    @action.prepare time, time / 1000, @getTime()
    @action.process particle

    @unregisterParticle particle if particle.dead

  registerParticle: (particle) ->
    @particles.push particle

  unregisterParticle: (particle) ->
    @died.push particle
    @subSystem?.emitFor particle
    @particles.splice @particles.indexOf(particle), 1

  getTime: -> new Date().valueOf()
