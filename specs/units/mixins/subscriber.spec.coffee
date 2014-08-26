
describe 'agt.mixins.Subscriber', ->
  [emitter, subscriber, spy] = []

  beforeEach ->
    class Emitter
      @include agt.mixins.Emitter

    class Subscriber
      @include agt.mixins.Subscriber

      constructor: (emitter, listener) ->
        @subscribe emitter, 'event', listener

    spy = jasmine.createSpy('spy')
    emitter = new Emitter
    subscriber = new Subscriber emitter, spy

  it 'subscribes to an emitter', ->
    expect(emitter.hasListeners()).toBeTruthy()

    emitter.dispatch('event')

    expect(spy).toHaveBeenCalled()

  it 'unsubscribes the listener with the emitter, the event and the listener', ->
    subscriber.unsubscribe emitter, 'event', spy

    expect(emitter.hasListeners()).toBeFalsy()

  it 'unsubscribes all the listeners for the emitter and the event', ->
    subscriber.unsubscribe emitter, 'event'

    expect(emitter.hasListeners()).toBeFalsy()

  it 'unsubscribes all the listeners for the emitter', ->
    subscriber.unsubscribe emitter

    expect(emitter.hasListeners()).toBeFalsy()

  it 'unsubscribes all the listeners', ->
    subscriber.unsubscribe()

    expect(emitter.hasListeners()).toBeFalsy()
