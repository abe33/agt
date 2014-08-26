
describe 'Signal', ->
  it 'has listeners', ->
    signal = new agt.Signal
    listener = ->

    signal.add listener

    expect(signal.listeners.length).toBe(1)

  it 'dispatchs message to its listeners', ->
    message = null
    signal = new agt.Signal
    listener = ->
      message = arguments[0]

    signal.add listener
    signal.dispatch "hello"

    expect(message).toBe("hello")

  it 'does not add the same listener twice', ->
    signal = new agt.Signal
    listener = ->

    signal.add listener
    signal.add listener

    expect(signal.listeners.length).toBe(1)

  it 'returns a subscription when adding a listener', ->
    signal = new agt.Signal
    listener = ->

    subscription = signal.add listener
    expect(signal.listeners.length).toBe(1)

    subscription.remove()

    expect(signal.listeners.length).toBe(0)

  it 'allows to remove listeners', ->
    signal = new agt.Signal
    listener = ->

    signal.add listener
    signal.remove listener

    expect(signal.listeners.length).toBe(0)

  it 'allows to register a listener with a context', ->
    signal = new agt.Signal
    context = {}
    listenerScope = null
    listener = ->
      listenerScope = this

    signal.add listener, context
    signal.dispatch "hello"

    expect(listenerScope).toBe(context)

  it 'allows to register a same listener twice with different context', ->
    signal = new agt.Signal
    context1 = {}
    context2 = {}
    listener = ->

    signal.add listener, context1
    signal.add listener, context2

    expect(signal.listeners.length).toBe(2)

  it 'allows to remove a listener bind with a context', ->
    signal = new agt.Signal
    context1 = foo: "Foo"
    context2 = foo: "Bar"
    lastCall = null
    listener = ->
      lastCall = this.foo

    signal.add listener, context1
    signal.add listener, context2

    signal.remove listener, context1

    signal.dispatch()

    expect(signal.listeners.length).toBe(1)
    expect(lastCall).toBe("Bar")

  it 'allows to register a listener for a single call', ->
    signal = new agt.Signal
    callCount = 0
    listener = ->
      callCount++

    signal.addOnce listener

    signal.dispatch()
    signal.dispatch()

    expect(callCount).toBe(1)

  it 'priorizes listeners', ->
    signal = new agt.Signal
    listenersCalls = []

    listener1 = ->
      listenersCalls.push "listener1"

    listener2 = ->
      listenersCalls.push "listener2"

    signal.add listener1
    signal.add listener2, null, 1

    signal.dispatch()

    expect(listenersCalls).toEqual(["listener2", "listener1"])

  it 'allows listeners registered for a single call to have a priority', ->
    signal = new agt.Signal
    listenersCalls = []

    listener1 = ->
      listenersCalls.push "listener1"

    listener2 = ->
      listenersCalls.push "listener2"

    signal.add listener1
    signal.addOnce listener2, null, 1

    signal.dispatch()

    expect(listenersCalls).toEqual(["listener2", "listener1"])

  it 'removes all listeners at once', ->
    signal = new agt.Signal

    listener1 = ->
    listener2 = ->

    signal.add listener1
    signal.add listener2

    signal.removeAll()
    expect(signal.listeners.length).toBe(0)

  it 'tells when listeners are registered', ->

    signal = new agt.Signal

    expect(signal.hasListeners()).toBeFalsy()

    listener = ->

    signal.add listener

    expect(signal.hasListeners()).toBeTruthy()

  describe 'with an asynchronous listener', ->

    it 'waits until the callback was called before going to the next listener', (done) ->

      listener1Called = false
      listener1Args = null
      listener2Args = null
      ended = false

      listener1 = (a,b,c,callback) ->
        setTimeout ->
          listener1Args = [a,b,c]
          listener1Called = true
          callback?()
        , 100

      listener2 = (a,b,c) ->
        listener2Args = [a,b,c]
        expect(listener1Called).toBeTruthy()
        expect(listener1Args).toEqual(listener2Args)

        done()

      signal = new agt.Signal

      signal.add listener1
      signal.add listener2

      signal.dispatch(1,2,3)

    it 'calls back the passed-in function at the end of the dispatch', (done) ->

      ended = false
      listener1 = (a, b, c, callback) -> setTimeout callback, 120
      listener2 = (a, b, c, callback) -> setTimeout callback, 120

      signal = new agt.Signal

      signal.add listener1
      signal.add listener2
      ms = new Date().valueOf()

      signal.dispatch 1, 2, 3, -> done()

  describe 'when a listener signature have been specified', ->
    it 'prevents invalid listener to be passed', ->

      signal = new agt.Signal 'a', 'b'

      expect(-> signal.add ->).toThrow()
      expect(-> signal.addOnce ->).toThrow()

      expect(-> signal.add (a, b) ->).not.toThrow()
      expect(-> signal.add (a, b, callback) ->).not.toThrow()
