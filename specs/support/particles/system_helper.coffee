
mockListener = (signal) -> (args...) ->
  global.currentResults[signal] = args

SIGNALS = [
  'particlesCreated'
  'particlesDied'
  'emissionStarted'
  'emissionFinished'
]

global.createListener = ->
  beforeEach ->
    global.currentResults = {}
    SIGNALS.forEach (m) => @system[m].add mockListener m

  afterEach -> SIGNALS.forEach (m) => @system[m].removeAll()

global.system = (source) ->
  should:
    emitting: ->
      it "#{source} is emitting", ->
        expect(this[source].emitting()).toBeTruthy()
    not:
      emitting: ->
        it "#{source} is not emitting", ->
          expect(this[source].emitting()).toBeFalsy()

  shouldHave: (value) ->
    particles: ->
      it "#{source} has #{value} particles", ->
        expect(this[source].particles.length).toBe(value)
    emissions: ->
      it "#{source} has #{value} emissions", ->
        expect(this[source].emissions.length).toBe(value)

    signal: (signal) ->
      it "#{source} has a #{signal} signal", ->
        target = this[source]
        targetSignal = target[signal]
        signalCalled = false
        listener = -> signalCalled = true
        listenersCount = targetSignal.listeners.length

        targetSignal.add listener
        expect(targetSignal.listeners.length).toBe(listenersCount + 1)

        targetSignal.dispatch()
        expect(signalCalled).toBeTruthy()

        targetSignal.remove listener
        expect(targetSignal.listeners.length).toBe(listenersCount)

    dispatched: (signal) ->
      it "#{source} has dispatched signal #{signal}", ->
        expect(global.currentResults[signal]).toBeDefined()

    started: ->
      it "#{source} has started", ->
        expect(this[source].running).toBeTruthy()
